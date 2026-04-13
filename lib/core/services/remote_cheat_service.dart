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
class RemoteCheatService {
  RemoteCheatService._();
  static final RemoteCheatService instance = RemoteCheatService._();

  // ── Server / Advertisement ────────────────────────────────────────────────
  HttpServer? _server;
  AuthenticityResult? _override;
  String? _localIp;
  String? _deviceName;

  // ── Discovery ─────────────────────────────────────────────────────────────
  RawDatagramSocket? _udpSocket;
  final _discoveredPeers = <String, MoneySensePeer>{}; // IP -> Peer
  Timer? _advertisementTimer;

  AuthenticityResult? get nextOverride => _override;
  String? get serverUrl => _server != null ? 'http://$_localIp:${_server!.port}' : null;
  String? get deviceName => _deviceName;

  /// Clears the pending override (called after a scan consumes it).
  void clearOverride() {
    _override = null;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> start() async {
    if (_server != null) return;

    try {
      _deviceName = await _getDeviceName();
      _localIp = await _getIPAddress();
      
      // 1. HTTP Server (The "API" to be controlled)
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      _server!.listen(_handleHttpRequest);

      // 2. UDP Advertisement (Tell others we are here)
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);
      _udpSocket!.broadcastEnabled = true;
      
      _advertisementTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        final msg = jsonEncode({'type': 'MONEYSENSE_PEER', 'name': _deviceName, 'ip': _localIp});
        _udpSocket?.send(utf8.encode(msg), InternetAddress('255.255.255.255'), 8888);
      });

      debugPrint('[RemoteCheatService] 🌐 Server & Advertisement active: $_deviceName ($_localIp)');
    } catch (e) {
      debugPrint('[RemoteCheatService] ✗ Failed to start: $e');
    }
  }

  Future<void> stop() async {
    _advertisementTimer?.cancel();
    _advertisementTimer = null;
    await _server?.close(force: true);
    _server = null;
    _udpSocket?.close();
    _udpSocket = null;
    _override = null;
    debugPrint('[RemoteCheatService] ⏹ Service stopped.');
  }

  // ── Controller Logic ──────────────────────────────────────────────────────

  /// Starts listening for other MoneySense devices. Returns a stream of discovered peers.
  Stream<List<MoneySensePeer>> startScanning() async* {
    // If not already bound to UDP, bind it
    if (_udpSocket == null) {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);
      _udpSocket!.broadcastEnabled = true;
    }

    _udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _udpSocket!.receive();
        if (dg != null) {
          try {
            final data = jsonDecode(utf8.decode(dg.data));
            if (data['type'] == 'MONEYSENSE_PEER') {
              final ip = data['ip'] as String;
              final name = data['name'] as String;
              
              // Don't discover ourselves
              if (ip != _localIp) {
                _discoveredPeers[ip] = MoneySensePeer(
                  name: name,
                  ip: ip,
                  lastSeen: DateTime.now(),
                );
              }
            }
          } catch (_) {}
        }
      }
    });

    while (true) {
      // Clean up stale peers (not seen for 10s)
      final now = DateTime.now();
      _discoveredPeers.removeWhere((_, p) => now.difference(p.lastSeen).inSeconds > 10);
      
      yield _discoveredPeers.values.toList();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // ── Internal Handlers ─────────────────────────────────────────────────────

  void _handleHttpRequest(HttpRequest request) {
    final path = request.uri.path;
    
    if (path == '/api/genuine') {
      _override = AuthenticityResult.genuine;
      _sendJsonResponse(request, {'status': 'ok'});
    } else if (path == '/api/counterfeit') {
      _override = AuthenticityResult.counterfeit;
      _sendJsonResponse(request, {'status': 'ok'});
    } else if (path == '/api/reset') {
      _override = null;
      _sendJsonResponse(request, {'status': 'ok'});
    } else if (path == '/api/status') {
      _sendJsonResponse(request, {'override': _override?.name ?? 'none'});
    } else {
      request.response..statusCode = HttpStatus.notFound..close();
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
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (var interface in interfaces) {
        if (!interface.name.contains('lo')) { // Not loopback
           return interface.addresses.first.address;
        }
      }
    } catch (_) {}
    return 'localhost';
  }
}

final remoteCheatServiceProvider = Provider((ref) => RemoteCheatService.instance);
