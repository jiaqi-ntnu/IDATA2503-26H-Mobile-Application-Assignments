import 'package:flutter/material.dart';

// Reusable helper widget to display a single trait (icon + text) on a meal card,
// such as cooking time, difficulty level, or affordability.
class MealItemTrait extends StatelessWidget {
  const MealItemTrait({
    super.key,
    required this.icon,
    required this.label,
  });

  // Icon representing the trait (e.g. Icons.schedule, Icons.work)
  final IconData icon;
  // Text label describing the trait (e.g. "20 min", "Simple", "$")
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        icon,
        size: 17,
        color: Colors.white,
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ]);
  }
}
