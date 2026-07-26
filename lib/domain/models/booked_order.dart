class BookedOrder {
  final String id;
  final String bookingRef;
  final List<String> serviceTitles;
  final String userName;
  final String userPhone;
  final String location;
  final String timeSlot;
  final String notes;
  final DateTime bookedAt;
  final String status;

  BookedOrder({
    required this.id,
    required this.bookingRef,
    required this.serviceTitles,
    required this.userName,
    required this.userPhone,
    required this.location,
    required this.timeSlot,
    required this.notes,
    required this.bookedAt,
    this.status = 'Confirmed & Dispatched to Nearby Provider',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingRef': bookingRef,
      'serviceTitles': serviceTitles,
      'userName': userName,
      'userPhone': userPhone,
      'location': location,
      'timeSlot': timeSlot,
      'notes': notes,
      'bookedAt': bookedAt.toIso8601String(),
      'status': status,
    };
  }

  factory BookedOrder.fromMap(Map<String, dynamic> map) {
    return BookedOrder(
      id: map['id'] ?? '',
      bookingRef: map['bookingRef'] ?? '',
      serviceTitles: List<String>.from(map['serviceTitles'] ?? []),
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      location: map['location'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      notes: map['notes'] ?? '',
      bookedAt: DateTime.tryParse(map['bookedAt'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Confirmed & Dispatched to Nearby Provider',
    );
  }
}
