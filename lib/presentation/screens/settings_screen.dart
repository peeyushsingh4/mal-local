import 'package:flutter/material.dart';
import '../../data/seed_data.dart';
import '../../domain/services/local_ai_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';

class SettingsScreen extends StatelessWidget {
  final ListingRepository repository;
  final LocalAiService aiService;

  const SettingsScreen({
    super.key,
    required this.repository,
    required this.aiService,
  });

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: BlinkitTheme.zomatoRed),
            SizedBox(width: 8),
            Text('Reset All Local Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all local listings from device storage and restore default seed data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BlinkitTheme.zomatoRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repository.clearAll();
      await repository.seedIfEmpty(getSeedListings());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local data reset successfully! Seed data restored.'),
            backgroundColor: BlinkitTheme.blinkitGreen,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security Posture Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BlinkitTheme.blinkitGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BlinkitTheme.blinkitGreen),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: BlinkitTheme.blinkitGreen),
                    SizedBox(width: 8),
                    Text(
                      'Security ADR 0002 Stance',
                      style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('• Zero hardcoded secrets in app binary'),
                Text('• Coarse sub-locality used (exact address prohibited)'),
                Text('• 100% On-device storage & AI offline fallback'),
                Text('• Zero telemetry exfiltration'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Management
          const Text('Data Management', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.restore, color: BlinkitTheme.zomatoRed),
              title: const Text('Reset All Local Data', style: TextStyle(fontWeight: FontWeight.bold, color: BlinkitTheme.zomatoRed)),
              subtitle: const Text('Wipe local IndexedDB/Preferences storage & restore defaults'),
              onTap: () => _confirmReset(context),
            ),
          ),

          const SizedBox(height: 32),

          // About Section
          const Center(
            child: Column(
              children: [
                Text('MAL LOCAL v1.0.0 (Flutter)', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Lab 01 · Flutter & Foundations • Bandra West, Mumbai', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
