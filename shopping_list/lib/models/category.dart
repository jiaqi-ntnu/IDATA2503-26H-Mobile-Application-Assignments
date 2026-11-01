import 'package:flutter/material.dart';

/// Available categories for grocery items in the application.
/// Using an enum provides type-safety and prevents typos in category identifiers.
enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

/// Represents the display metadata for a specific category.
/// Contains the user-facing title and the color indicator used in the UI.
class Category {
  const Category(this.title, this.color);

  /// The human-readable name of the category (e.g., 'Vegetables', 'Fruit').
  final String title;

  /// The visual accent color associated with the category for quick UI identification.
  final Color color;
}
