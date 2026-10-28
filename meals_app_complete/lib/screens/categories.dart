import 'package:flutter/material.dart';

import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/widgets/category_grid_item.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/models/category.dart';

// Displays a grid of meal categories with an animated entrance effect.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    required this.availableMeals,
  });

  // Filtered list of meals based on current dietary filters.
  final List<Meal> availableMeals;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

// SingleTickerProviderStateMixin provides the Ticker needed for the AnimationController.
class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Sets up an animation controller spanning 300ms from 0.0 to 1.0.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );

    // Starts the animation as soon as the screen is initialized.
    _animationController.forward();
  }

  @override
  void dispose() {
    // Crucial: dispose the AnimationController to prevent memory leaks when widget is removed.
    _animationController.dispose();
    super.dispose();
  }

  // Filters meals that belong to the tapped category and navigates to the MealsScreen.
  void _selectCategory(BuildContext context, Category category) {
    final filteredMeals = widget.availableMeals
        .where((meal) => meal.categories.contains(category.id))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealsScreen(
          title: category.title,
          meals: filteredMeals,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      // Cached child passed to builder so it is created only once:
      child: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns in the grid
          childAspectRatio: 3 / 2, // Width to height ratio of each tile
          crossAxisSpacing: 20, // Horizontal gap between tiles
          mainAxisSpacing: 20, // Vertical gap between tiles
        ),
        children: [
          for (final category in availableCategories)
            CategoryGridItem(
              category: category,
              onSelectCategory: () {
                _selectCategory(context, category);
              },
            )
        ],
      ),
      // Applies a slide-up transition from an offset of 30% below to its final position.
      builder: (context, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: child,
      ),
    );
  }
}
