import 'package:flutter/material.dart';

class ListingCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final Color bgTint;

  const ListingCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgTint,
  });

  static const List<ListingCategory> all = [
    ListingCategory(
      id: 'food',
      name: 'Food & Tiffin',
      icon: '🍱',
      color: Color(0xFFD4A300),
      bgTint: Color(0xFFFFF9E6),
    ),
    ListingCategory(
      id: 'services',
      name: 'Services',
      icon: '🔧',
      color: Color(0xFF0C831F),
      bgTint: Color(0xE8F7EEFF),
    ),
    ListingCategory(
      id: 'goods',
      name: 'Goods & Items',
      icon: '📦',
      color: Color(0xFF0284C7),
      bgTint: Color(0xFFF0F9FF),
    ),
    ListingCategory(
      id: 'lending',
      name: 'Lending',
      icon: '🤝',
      color: Color(0xFF16A34A),
      bgTint: Color(0xFFF0FDF4),
    ),
    ListingCategory(
      id: 'requests',
      name: 'Requests',
      icon: '🙏',
      color: Color(0xFFDB2777),
      bgTint: Color(0xFFFDF2F8),
    ),
    ListingCategory(
      id: 'skills',
      name: 'Skills',
      icon: '🎓',
      color: Color(0xFF7C3AED),
      bgTint: Color(0xFFF5F3FF),
    ),
    ListingCategory(
      id: 'other',
      name: 'Other',
      icon: '📌',
      color: Color(0xFF64748B),
      bgTint: Color(0xFFF8FAFC),
    ),
  ];

  static ListingCategory getById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.last,
    );
  }
}
