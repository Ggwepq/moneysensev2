import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../../../core/services/remote_cheat_service.dart';

class RemoteCommanderScreen extends ConsumerStatefulWidget {
  const RemoteCommanderScreen({super.key});

  @override
  ConsumerState<RemoteCommanderScreen> createState() => _RemoteCommanderScreenState();
}

class _RemoteCommanderScreenState extends ConsumerState<RemoteCommanderScreen> with SingleTickerProviderStateMixin {
  MoneySensePeer? _selectedPeer;
  late AnimationController _radarController;
  Stream<List<MoneySensePeer>>? _scanStream;
  int _controlTab = 0; // 0 = Identification, 1 = Verification
  
  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _startScan();
  }

  void _startScan() {
    setState(() {
      _scanStream = RemoteCheatService.instance.startScanning();
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    RemoteCheatService.instance.stopScanning();
    super.dispose();
  }

  Future<void> _sendCommand(String cmd) async {
    if (_selectedPeer == null) return;
    HapticFeedback.lightImpact();
    
    try {
      final url = Uri.parse('http://${_selectedPeer!.ip}:8080/api/$cmd');
      await http.get(url).timeout(const Duration(seconds: 2));
      
      if (mounted) {
        String label = cmd.toUpperCase();
        Color color = Colors.grey;
        
        if (cmd == 'genuine') { label = '✓ GENUINE'; color = Colors.green; }
        else if (cmd == 'counterfeit') { label = '✗ COUNTERFEIT'; color = Colors.red; }
        else if (cmd.startsWith('denom/')) { 
          final d = cmd.split('/').last;
          label = '₱$d FORCED';
          color = const Color(0xFF00E3FD);
        }
        else if (cmd == 'reset') { label = 'RESET'; color = Colors.grey; }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent: $label to ${_selectedPeer!.name}'),
            backgroundColor: color,
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send command to ${_selectedPeer!.name}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010F1C),
      appBar: AppBar(
        title: const Text('Commander Radar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedPeer != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                RemoteCheatService.instance.stopScanning();
                setState(() => _selectedPeer = null);
                _startScan();
              },
            ),
        ],
      ),
      body: _selectedPeer == null ? _buildRadar() : _buildControlPanel(),
    );
  }

  Widget _buildRadar() {
    return StreamBuilder<List<MoneySensePeer>>(
      stream: _scanStream,
      builder: (context, snapshot) {
        final peers = snapshot.data ?? [];
        
        return Column(
          children: [
            const Gap(40),
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RadarPainter(_radarController.value),
                      child: Center(
                        child: Icon(
                          Icons.radar_rounded,
                          size: 48,
                          color: const Color(0xFF00E3FD).withOpacity(0.5 + (0.5 * (1 - _radarController.value))),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Gap(40),
            Text(
              peers.isEmpty ? 'Scanning for devices...' : '${peers.length} Devices Found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1.2,
                fontSize: 14,
              ),
            ),
            const Gap(20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: peers.length,
                itemBuilder: (context, index) {
                  final peer = peers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF00E3FD),
                        child: Icon(Icons.phone_android_rounded, color: Colors.black, size: 20),
                      ),
                      title: Text(
                        peer.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        peer.ip,
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPeer = peer);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        // ── Peer Info ───────────────────────────────────────────────────────
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.phone_android_rounded, size: 36, color: Color(0xFF00E3FD)),
        ),
        const Gap(8),
        Text(
          _selectedPeer!.name,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          _selectedPeer!.ip,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        const Gap(20),

        // ── Tab Selector ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTab('Identification', 0, Icons.search_rounded),
                _buildTab('Verification', 1, Icons.verified_user_rounded),
              ],
            ),
          ),
        ),
        const Gap(24),

        // ── Tab Content ─────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _controlTab == 0
                ? _buildIdentificationTab()
                : _buildVerificationTab(),
          ),
        ),

        // ── Reset Button ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextButton.icon(
            onPressed: () => _sendCommand('reset'),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 18),
            label: const Text('Reset All Overrides', style: TextStyle(color: Colors.white54)),
          ),
        ),
        const Gap(8),
      ],
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isActive = _controlTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _controlTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00E3FD).withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF00E3FD).withOpacity(0.4) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? const Color(0xFF00E3FD) : Colors.white38),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF00E3FD) : Colors.white38,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Identification Tab ──────────────────────────────────────────────────

  Widget _buildIdentificationTab() {
    const denominations = [
      _DenomInfo('1', 'coin', Color(0xFFB0BEC5), '₱1'),
      _DenomInfo('5', 'coin', Color(0xFFFFD54F), '₱5'),
      _DenomInfo('10', 'coin', Color(0xFF90A4AE), '₱10'),
      _DenomInfo('20', 'bill', Color(0xFFFF7043), '₱20'),
      _DenomInfo('50', 'bill', Color(0xFFEF5350), '₱50'),
      _DenomInfo('100', 'bill', Color(0xFFAB47BC), '₱100'),
      _DenomInfo('200', 'bill', Color(0xFF66BB6A), '₱200'),
      _DenomInfo('500', 'bill', Color(0xFFFFC107), '₱500'),
      _DenomInfo('1000', 'bill', Color(0xFF42A5F5), '₱1000'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Force the scanned denomination to show a specific value.',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        const Gap(16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
          ),
          itemCount: denominations.length,
          itemBuilder: (context, index) {
            final d = denominations[index];
            return _buildDenomButton(d);
          },
        ),
        const Gap(16),
        Center(
          child: TextButton.icon(
            onPressed: () => _sendCommand('denom/reset'),
            icon: Icon(Icons.clear_rounded, color: Colors.white.withOpacity(0.4), size: 16),
            label: Text('Clear Denomination Override', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDenomButton(_DenomInfo d) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendCommand('denom/${d.value}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: d.color.withOpacity(0.5), width: 2),
            gradient: LinearGradient(
              colors: [d.color.withOpacity(0.15), d.color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                d.type == 'coin' ? Icons.circle_outlined : Icons.credit_card_rounded,
                color: d.color,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                d.label,
                style: TextStyle(
                  color: d.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                d.type,
                style: TextStyle(color: d.color.withOpacity(0.5), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Verification Tab ────────────────────────────────────────────────────

  Widget _buildVerificationTab() {
    return Column(
      children: [
        Text(
          'Force the authenticity result to show genuine or counterfeit.',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        const Gap(24),
        _buildActionButton(
          label: 'FORCE GENUINE',
          color: Colors.green,
          icon: Icons.check_circle_rounded,
          onTap: () => _sendCommand('genuine'),
        ),
        const Gap(16),
        _buildActionButton(
          label: 'FORCE COUNTERFEIT',
          color: Colors.red,
          icon: Icons.error_rounded,
          onTap: () => _sendCommand('counterfeit'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const Gap(8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DenomInfo {
  final String value;
  final String type;
  final Color color;
  final String label;

  const _DenomInfo(this.value, this.type, this.color, this.label);
}

class _RadarPainter extends CustomPainter {
  final double animationValue;
  _RadarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF00E3FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Static concentric circles
    for (var i = 1; i <= 4; i++) {
       canvas.drawCircle(center, (size.width / 8) * i, paint..color = const Color(0xFF00E3FD).withOpacity(0.1));
    }

    // Expanding pulses
    for (var i = 0; i < 3; i++) {
      final value = (animationValue + (i / 3)) % 1;
      final opacity = (1 - value).clamp(0.0, 1.0);
      final radius = (size.width / 2) * value;
      
      canvas.drawCircle(
        center, 
        radius, 
        paint..color = const Color(0xFF00E3FD).withOpacity(opacity * 0.4)
             ..strokeWidth = 2.0
      );
    }
    
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF00E3FD).withOpacity(0.0),
          const Color(0xFF00E3FD).withOpacity(0.2),
        ],
        stops: const [0.75, 1.0],
        transform: GradientRotation(animationValue * 2 * 3.14159),
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
      
    canvas.drawCircle(center, size.width / 2, sweepPaint);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => true;
}
