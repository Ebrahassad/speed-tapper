import 'package:flutter/material.dart';
import '../../../core/settings/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
  });

  final GameSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GameSettings get settings => widget.settings;

  Future<void> _save() async {
    await settings.save();
    if (mounted) setState(() {});
  }

  Future<void> _resetScore() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تصفير النتائج؟'),
          content: const Text(
            'سيتم حذف أعلى نتيجة وأفضل مستوى. لا يمكن التراجع عن ذلك.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('تصفير'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await settings.resetProgress();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تصفير النتائج'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05050D),
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: const Color(0xFF0D0B1E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle('الصوت'),
          _switchTile(
            icon: Icons.volume_up,
            title: 'المؤثرات الصوتية',
            value: settings.soundEnabled,
            onChanged: (value) {
              setState(() => settings.soundEnabled = value);
              _save();
            },
          ),
          _switchTile(
            icon: Icons.music_note,
            title: 'الموسيقى',
            value: settings.musicEnabled,
            onChanged: (value) {
              setState(() => settings.musicEnabled = value);
              _save();
            },
          ),
          const SizedBox(height: 12),
          _sectionTitle('اللعب'),
          _switchTile(
            icon: Icons.vibration,
            title: 'الاهتزاز',
            value: settings.vibrationEnabled,
            onChanged: (value) {
              setState(() => settings.vibrationEnabled = value);
              _save();
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle('الإحصائيات'),
          _statCard(
            Icons.emoji_events,
            'أعلى نتيجة',
            '${settings.highScore}',
          ),
          _statCard(
            Icons.layers,
            'أفضل مستوى',
            '${settings.bestLevel}',
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _resetScore,
            icon: const Icon(Icons.delete_outline),
            label: const Text('تصفير النتائج'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      color: const Color(0xFF0D0B1E),
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: const Color(0xFF00E5FF),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      color: const Color(0xFF0D0B1E),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFE600),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
