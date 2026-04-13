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
  
  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  Future<void> _sendCommand(String cmd) async {
    if (_selectedPeer == null) return;
    HapticFeedback.lightImpact();
    
    try {
      final url = Uri.parse('http://${_selectedPeer!.ip}:8080/api/$cmd');
      await http.get(url).timeout(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent: ${cmd.toUpperCase()} to ${_selectedPeer!.name}'),
            backgroundColor: cmd == 'genuine' ? Colors.green : (cmd == 'counterfeit' ? Colors.red : Colors.grey),
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
              onPressed: () => setState(() => _selectedPeer = null),
            ),
        ],
      ),
      body: _selectedPeer == null ? _buildRadar() : _buildControlPanel(),
    );
  }

  Widget _buildRadar() {
    return StreamBuilder<List<MoneySensePeer>>(
      stream: RemoteCheatService.instance.startScanning(),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_android_rounded, size: 48, color: Color(0xFF00E3FD)),
          ),
          const Gap(16),
          Text(
            'Controlling: ${_selectedPeer!.name}',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            _selectedPeer!.ip,
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
          const Gap(48),
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
          const Gap(40),
          TextButton.icon(
            onPressed: () => _sendCommand('reset'),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 18),
            label: const Text('Reset to AI Results', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
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
