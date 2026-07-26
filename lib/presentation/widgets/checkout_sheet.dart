import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../theme/blinkit_theme.dart';

class CheckoutSheet extends StatefulWidget {
  final List<Listing> selectedListings;
  final String userLocation;
  final VoidCallback onClearCart;
  final VoidCallback onOrderConfirmed;

  const CheckoutSheet({
    super.key,
    required this.selectedListings,
    required this.userLocation,
    required this.onClearCart,
    required this.onOrderConfirmed,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  String _selectedSlot = 'As soon as possible (8 mins)';
  final TextEditingController _noteController = TextEditingController();
  bool _isConfirming = false;

  final List<String> _timeSlots = [
    'As soon as possible (8 mins)',
    'Today Evening (6 PM - 8 PM)',
    'Tomorrow Morning (9 AM - 12 PM)',
    'Tomorrow Afternoon (2 PM - 5 PM)',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _processCheckout() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Show Success Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: BlinkitTheme.blinkitGreenLight,
              child: Icon(Icons.check_circle, color: BlinkitTheme.blinkitGreen, size: 40),
            ),
            SizedBox(height: 12),
            Text(
              'Service Request Placed!',
              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your request for ${widget.selectedListings.length} service(s) in ${widget.userLocation} has been sent to nearby providers.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BlinkitTheme.blinkitYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BlinkitTheme.blinkitYellow),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time Slot:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(_selectedSlot, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BlinkitTheme.blinkitGreen)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Location:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(widget.userLocation, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BlinkitTheme.blinkitGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close checkout sheet
                widget.onClearCart();
                widget.onOrderConfirmed();
              },
              child: const Text('Back to Home Board', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: BlinkitTheme.blinkitGreen, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Service Checkout (${widget.selectedListings.length})',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),

          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Selected Services List
                const Text('Selected Services & Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),

                ...widget.selectedListings.map((item) {
                  final cat = ListingCategory.getById(item.categoryId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? BlinkitTheme.darkElevated : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cat.bgTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('📍 ${item.area} • ${item.type == ListingType.offer ? "Offer" : "Request"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Text(
                          'FREE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: BlinkitTheme.blinkitGreen),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Location Delivery Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BlinkitTheme.blinkitYellow.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BlinkitTheme.blinkitYellow),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: BlinkitTheme.swiggyOrange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Service Location', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            Text(widget.userLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Preferred Timing Slot Dropdown
                const Text('Preferred Service Timing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedSlot,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _timeSlots.map((slot) {
                    return DropdownMenuItem(
                      value: slot,
                      child: Text(slot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSlot = val);
                  },
                ),

                const SizedBox(height: 16),

                // Special Notes Text Field
                const Text('Notes / Specific Instructions (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'e.g. Please bring extra tools / call before arrival',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Confirm Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: BlinkitTheme.blinkitGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isConfirming ? null : _processCheckout,
              icon: _isConfirming
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.arrow_forward_rounded, size: 20),
              label: Text(
                _isConfirming ? 'Processing Checkout...' : 'Confirm Service Request · Free Checkout',
                style: const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
