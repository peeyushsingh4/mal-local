import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booked_order.dart';

class OrderService {
  static const String _ordersKey = 'localhive_booked_orders_v1';

  static Future<List<BookedOrder>> getBookedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_ordersKey) ?? [];
    return raw
        .map((str) => BookedOrder.fromMap(jsonDecode(str)))
        .toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  }

  static Future<void> saveOrder(BookedOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBookedOrders();
    current.insert(0, order);
    final rawList = current.map((o) => jsonEncode(o.toMap())).toList();
    await prefs.setStringList(_ordersKey, rawList);
  }

  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }
}
