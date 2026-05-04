import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scanner/data/datasources/authenticity_service.dart';

/// Represents a MoneySense device discovered on the network.
class MoneySensePeer {
  final String name;
  final String ip;
  final DateTime lastSeen;

  MoneySensePeer({required this.name, required this.ip, required this.lastSeen});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneySensePeer && runtimeType == other.runtimeType && ip == other.ip;

  @override
  int get hashCode => ip.hashCode;
}

/// A service that handles both "Discoverable" mode (being controlled)
/// and "Controller" mode (scanning for and controlling other devices).
///
/// Design notes:
/// • The HTTP server and UDP advertisement socket are long-lived and share
///   the same lifetime as the app.
/// • The UDP *scan* socket is a separate ephemeral socket that is opened
///   when [startScanning] is called and closed when [stopScanning] is called
///   (or the stream is cancelled).  This prevents the advertisement socket
///   from being closed by scanner teardown.
/// • [_override] is PERSISTENT: once a remote device sets it, it stays until
///   the remote explicitly calls /api/reset.  This means retries on the
///   target device will always get the same forced result without the remote
///   needing to spam commands.
class RemoteCheatService {
  RemoteCheatService._();
  static final RemoteCheatService instance = RemoteCheatService._();

  // ── Server / Advertisement ────────────────────────────────────────────────
  HttpServer? _server;

  /// Persistent override — NOT cleared on read.  Only /api/reset clears it.
  AuthenticityResult? _override;

  String? _localIp;
  String? _deviceName;

  // ── Advertisement (outbound UDP) ──────────────────────────────────────────
  RawDatagramSocket? _advSocket;
  Timer? _advertisementTimer;

  // ── Discovery (inbound UDP, scan mode) ───────────────────────────────────
  /// Separate socket used only while the Commander screen is open.
  /// Closed independently so that stopping the scan never breaks the adv socket.
  RawDatagramSocket? _scanSocket;
  StreamController<List<MoneySensePeer>>? _scanController;
  Timer? _scanPruneTimer;
  final _discoveredPeers = <String, MoneySensePeer>{}; // IP → Peer

  AuthenticityResult? get nextOverride => _override;
  String? get serverUrl => _server != null ? 'http://$_localIp:${_server!.port}' : null;
  String? get deviceName => _deviceName;

  /// Returns true if the HTTP server is already running.
  bool get isRunning => _server != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Starts the HTTP server and UDP advertisement.  Safe to call multiple times.
  Future<void> start() async {
    if (_server != null) return;

    try {
      _deviceName = await _getDeviceName();
      _localIp = await _getIPAddress();

      // 1. HTTP Server (the "API" to be controlled)
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      _server!.listen(_handleHttpRequest);

      // 2. UDP Advertisement — outbound-only socket
      _advSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _advSocket!.broadcastEnabled = true;

      _advertisementTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        final msg = jsonEncode({
          'type': 'MONEYSENSE_PEER',
          'name': _deviceName,
          'ip': _localIp,
        });
        _advSocket?.send(
          utf8.encode(msg),
          InternetAddress('255.255.255.255'),
          8888,
        );
      });

      debugPrint(
          '[RemoteCheatService] 🌐 Server & Advertisement active: $_deviceName ($_localIp)');
    } catch (e) {
      debugPrint('[RemoteCheatService] ✗ Failed to start: $e');
    }
  }

  /// Stops the HTTP server and advertisement.  Does NOT touch the scan socket.
  Future<void> stop() async {
    _advertisementTimer?.cancel();
    _advertisementTimer = null;
    await _server?.close(force: true);
    _server = null;
    _advSocket?.close();
    _advSocket = null;
    _override = null;
    debugPrint('[RemoteCheatService] ⏹ Service stopped.');
  }

  // ── Controller Logic ──────────────────────────────────────────────────────

  /// Returns a broadcast stream of currently-visible peers.
  ///
  /// A **new** UDP socket is opened on port 8888 each time this is called,
  /// completely independent of the advertisement socket.  Cancelling the
  /// stream subscription (or calling [stopScanning]) closes that socket so a
  /// fresh scan can begin immediately — no app restart required.
  Stream<List<MoneySensePeer>> startScanning() {
    // If a previous scan is still open, close it cleanly first.
    stopScanning();

    _discoveredPeers.clear();
    _scanController = StreamController<List<MoneySensePeer>>(
      onCancel: stopScanning,
    );

    _openScanSocket();

    // Prune stale peers and emit every second.
    _scanPruneTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      _discoveredPeers
          .removeWhere((_, p) => now.difference(p.lastSeen).inSeconds > 10);
      if (!(_scanController?.isClosed ?? true)) {
        _scanController?.add(_discoveredPeers.values.toList());
      }
    });

    return _scanController!.stream;
  }

  /// Cleanly tears down the scan socket and timer.
  /// Safe to call even when no scan is running.
  void stopScanning() {
    _scanPruneTimer?.cancel();
    _scanPruneTimer = null;
    _scanSocket?.close();
    _scanSocket = null;
    _scanController?.close();
    _scanController = null;
  }

  Future<void> _openScanSocket() async {
    try {
      _scanSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);
      _scanSocket!.broadcastEnabled = true;

      _scanSocket!.listen(
        (event) {
          if (event != RawSocketEvent.read) return;
          final dg = _scanSocket?.receive();
          if (dg == null) return;
          try {
            final data = jsonDecode(utf8.decode(dg.data));
            if (data['type'] == 'MONEYSENSE_PEER') {
              final ip = data['ip'] as String;
              final name = data['name'] as String;
              // Never add ourselves.
              if (ip != _localIp) {
                _discoveredPeers[ip] = MoneySensePeer(
                  name: name,
                  ip: ip,
                  lastSeen: DateTime.now(),
                );
              }
            }
          } catch (_) {}
        },
        onError: (_) {
          // Socket closed — scan ended normally.
        },
        onDone: () {
          // Socket closed — scan ended normally.
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[RemoteCheatService] ✗ Failed to open scan socket: $e');
    }
  }

  // ── Internal Handlers ─────────────────────────────────────────────────────

  void _handleHttpRequest(HttpRequest request) {
    final path = request.uri.path;

    if (path == '/api/genuine') {
      // Persistent override — stays until /api/reset is called.
      _override = AuthenticityResult.genuine;
      _sendJsonResponse(request, {'status': 'ok', 'override': 'genuine'});
      debugPrint('[RemoteCheatService] 📡 Override set → GENUINE (persistent)');
    } else if (path == '/api/counterfeit') {
      _override = AuthenticityResult.counterfeit;
      _sendJsonResponse(request, {'status': 'ok', 'override': 'counterfeit'});
      debugPrint('[RemoteCheatService] 📡 Override set → COUNTERFEIT (persistent)');
    } else if (path == '/api/reset') {
      _override = null;
      _sendJsonResponse(request, {'status': 'ok', 'override': 'none'});
      debugPrint('[RemoteCheatService] 📡 Override cleared → AI results');
    } else if (path == '/api/status') {
      _sendJsonResponse(request, {'override': _override?.name ?? 'none'});
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }

  void _sendJsonResponse(HttpRequest request, Map<String, dynamic> data) {
    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data))
      ..close();
  }

  Future<String> _getDeviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await info.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await info.iosInfo;
        return iosInfo.name;
      }
    } catch (_) {}
    return 'MoneySense Device';
  }

  Future<String> _getIPAddress() async {
    try {
      final interfaces =
          await NetworkInterface.list(type: InternetAddressType.IPv4);
      
      // Preferred interfaces: wlan, wifi, eth (not loopback, not cellular)
      final preferredInterface = interfaces.cast<NetworkInterface?>().firstWhere(
        (i) {
          final name = i!.name.toLowerCase();
          return name.contains('wlan') || name.contains('wifi') || name.contains('eth');
        },
        orElse: () => null,
      );

      if (preferredInterface != null) {
        return preferredInterface.addresses.first.address;
      }

      // Fallback: first non-loopback
      for (var interface in interfaces) {
        if (!interface.name.contains('lo')) {
          return interface.addresses.first.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1'; // Safer fallback than 'localhost' for URI parsing
  }
}

final remoteCheatServiceProvider =
    Provider((ref) => RemoteCheatService.instance);
