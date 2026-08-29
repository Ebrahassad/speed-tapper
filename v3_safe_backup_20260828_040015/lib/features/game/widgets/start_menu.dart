import 'package:flutter/material.dart';

class StartMenu extends StatelessWidget {
  const StartMenu({
    super.key,
    required this.highScore,
    required this.onPlay,
    required this.onSettings,
  });

  final int highScore;
  final VoidCallback onPlay;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bolt,
              size: 72,
              color: Color(0xFF00E5FF),
              shadows: [
                Shadow(
                  color: Color(0xFF00E5FF),
                  blurRadius: 30,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'NEON',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 7,
              ),
            ),
            const Text(
              'BREAKER PRO',
              style: TextStyle(
                color: Color(0xFFFF007F),
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'اكسر الطوب • ابنِ الكومبو • حطم الرقم القياسي',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0B1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                ),
              ),
              child: Text(
                'أعلى نتيجة  $highScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('ابدأ اللعب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF007F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSettings,
                icon: const Icon(Icons.settings),
                label: const Text('الإعدادات'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00E5FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                    color: Color(0xFF00E5FF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
