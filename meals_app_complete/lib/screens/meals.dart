import 'package:flutter/material.dart';

import 'package:meals/models/meal.dart';
import 'package:meals/screens/meal_details.dart';
import 'package:meals/widgets/meal_item.dart';

// Screen widget responsible for displaying a list of meals.
// It can be used as a standalone screen with its own AppBar (e.g., viewing a category)
// or embedded within another screen (e.g., in the Favorites tab of TabsScreen).
class MealsScreen extends StatelessWidget {
  const MealsScreen({
    super.key,
    this.title,
    required this.meals,
  });

  // Optional screen title. If null, no Scaffold or AppBar is created (used for tabs).
  final String? title;
  // The list of meals to be displayed.
  final List<Meal> meals;

  // Handles meal item selection by navigating to the detailed view of the chosen meal.
  void selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealDetailsScreen(
          meal: meal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default fallback UI displayed when there are no meals in the list.
    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Uh oh ... nothing here!',
            // style: Theme.of(context).textTheme.headlineLarge
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try selecting a different category!',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );

    // If meals exist, replace the fallback UI with a scrollable list.
    // ListView.builder efficiently creates items on demand as they scroll into view.
    if (meals.isNotEmpty) {
      content = ListView.builder(
        itemCount: meals.length,
        itemBuilder: (ctx, index) => MealItem(
          meal: meals[index],
          onSelectMeal: (meal) {
            selectMeal(context, meal);
          },
        ),
      );
    }

    // If no title is provided, return just the content (for embedding inside another Scaffold, e.g. TabsScreen).
    if (title == null) {
      return content;
    }

    // Otherwise, wrap the content in a full Scaffold with its own AppBar.
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: content,
    );
  }
}
