import 'package:flutter/material.dart';

// Data model representing a meal category (e.g., Italian, Quick & Easy).
class Category {
  const Category({
    required this.id,
    required this.title,
    this.color = Colors.orange, // Default accent color if none is specified
  });

  // Unique identifier for the category (used to link with Meal.categories).
  final String id;
  // Human-readable title of the category.
  final String title;
  // Background/accent color used when displaying this category in the grid.
  final Color color;
}
