import 'package:flutter/material.dart';

import 'package:meals/models/category.dart';

// Widget rendering an individual category tile in the grid.
class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onSelectCategory,
  });

  // Category data object containing title, color, and id
  final Category category;
  // Callback invoked when this tile is pressed
  final void Function() onSelectCategory;

  @override
  Widget build(BuildContext context) {
    // InkWell provides tap handling and an interactive ripple (splash) effect.
    return InkWell(
      onTap: onSelectCategory,
      splashColor: Theme.of(context).primaryColor,
      // Matches the Container border radius so the ripple is clipped properly
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Two-stop linear gradient using the category's theme color
            gradient: LinearGradient(
              colors: [
                category.color.withValues(alpha: 0.55),
                category.color.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
        child: Text(
          category.title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}
