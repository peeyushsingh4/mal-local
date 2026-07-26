import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/local_ai_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';

class PulseScreen extends StatefulWidget {
  final ListingRepository repository;
  final LocalAiService aiService;

  const PulseScreen({
    super.key,
    required this.repository,
    required this.aiService,
  });

  @override
  State<PulseScreen> createState() => _PulseScreenState();
}

class _PulseScreenState extends State<PulseScreen> {
  List<Listing> _allListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final listings = await widget.repository.getAll();
    setState(() {
      _allListings = listings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _allListings.length;
    final activeCount = _allListings.where((l) => l.status == ListingStatus.active).length;
    final communityScore = total == 0 ? 0 : ((activeCount / total) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Neighborhood Pulse'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: BlinkitTheme.blinkitGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bandra West Activity Score',
                    style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 12),

                  // Stats Row Cards
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Listings', '$total', BlinkitTheme.blinkitYellow)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Active', '$activeCount', BlinkitTheme.blinkitGreen)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Health Score', '$communityScore%', const Color(0xFF0284C7))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Category Breakdown Distribution Chart
                  const Text(
                    'Category Activity Breakdown',
                    style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? BlinkitTheme.darkCardBg : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: ListingCategory.all.map((cat) {
                        final count = _allListings.where((l) => l.categoryId == cat.id).length;
                        final ratio = total == 0 ? 0.0 : (count / total);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${cat.icon} ${cat.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('$count listings', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 10,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEDF1F7),
                                  color: cat.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BlinkitTheme.darkCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
