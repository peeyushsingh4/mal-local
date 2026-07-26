import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/booked_order.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/order_service.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;

  String _selectedSlot = 'As soon as possible (8 mins)';
  bool _isConfirming = false;
  BookedOrder? _confirmedOrderReceipt;

  final List<String> _timeSlots = [
    'As soon as possible (8 mins)',
    'Today Evening (6 PM - 8 PM)',
    'Tomorrow Morning (9 AM - 12 PM)',
    'Tomorrow Afternoon (2 PM - 5 PM)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Resident Neighbor');
    _phoneController = TextEditingController(text: '+91 98200 12345');
    _locationController = TextEditingController(text: widget.userLocation);
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _processCheckout() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final loc = _locationController.text.trim();

    if (name.isEmpty || phone.isEmpty || loc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out Name, Phone, and Location'),
          backgroundColor: BlinkitTheme.zomatoRed,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final bookingRef = '#LH-${Random().nextInt(89999) + 10000}';
    final order = BookedOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingRef: bookingRef,
      serviceTitles: widget.selectedListings.map((l) => l.title).toList(),
      userName: name,
      userPhone: phone,
      location: loc,
      timeSlot: _selectedSlot,
      notes: _noteController.text.trim(),
      bookedAt: DateTime.now(),
    );

    // Save order locally so user can view active orders anytime!
    await OrderService.saveOrder(order);

    setState(() {
      _isConfirming = false;
      _confirmedOrderReceipt = order;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Output Confirmation Receipt Box
    if (_confirmedOrderReceipt != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: BlinkitTheme.blinkitGreenLight,
                child: Icon(Icons.check_circle, color: BlinkitTheme.blinkitGreen, size: 44),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Service Booking Confirmed!',
                style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
            const Center(
              child: Text(
                'Your request has been saved and dispatched to nearby local providers.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Detailed Output Receipt Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? BlinkitTheme.darkElevated : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BlinkitTheme.blinkitGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Booking Ref ID:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(
                        _confirmedOrderReceipt!.bookingRef,
                        style: const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, color: BlinkitTheme.blinkitGreen),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _buildReceiptRow('Customer Name:', _confirmedOrderReceipt!.userName),
                  _buildReceiptRow('Contact Phone:', _confirmedOrderReceipt!.userPhone),
                  _buildReceiptRow('Service Address:', _confirmedOrderReceipt!.location),
                  _buildReceiptRow('Timing Slot:', _confirmedOrderReceipt!.timeSlot),
                  if (_confirmedOrderReceipt!.notes.isNotEmpty)
                    _buildReceiptRow('Instructions:', _confirmedOrderReceipt!.notes),
                  const SizedBox(height: 8),
                  const Text('Requested Services:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  ..._confirmedOrderReceipt!.serviceTitles.map((s) => Text('• $s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlinkitTheme.blinkitGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onClearCart();
                  widget.onOrderConfirmed();
                },
                child: const Text('Done · View My Ordered Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                  const Icon(Icons.shopping_cart, color: BlinkitTheme.blinkitGreen, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout (${widget.selectedListings.length} Service)',
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

          const SizedBox(height: 8),
          const Divider(),

          Expanded(
            child: ListView(
              children: [
                // Selected Services List
                const Text('Items & Services in Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cat.bgTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
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

                // Customer Details Section
                const Text('Contact & Delivery Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Your Name *',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Location Field
                TextField(
                  controller: _locationController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Delivery / Service Address *',
                    isDense: true,
                    prefixIcon: const Icon(Icons.location_on, size: 18, color: BlinkitTheme.swiggyOrange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 12),

                // Preferred Timing Slot Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedSlot,
                  decoration: InputDecoration(
                    labelText: 'Preferred Timing *',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

                const SizedBox(height: 12),

                // Notes Field
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Instructions for Provider (Optional)',
                    hintText: 'e.g. Please bring tools / call before coming',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Confirm Button
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

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
