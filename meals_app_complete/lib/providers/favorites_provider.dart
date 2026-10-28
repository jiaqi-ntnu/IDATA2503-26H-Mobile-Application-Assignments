import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meals/models/meal.dart';

// StateNotifier managing the user's list of favorite meals.
// In Riverpod, StateNotifier allows mutating state by replacing `state` with an immutable new list.
class FavoriteMealsNotifier extends StateNotifier<List<Meal>> {
  // Starts with an empty list of favorites.
  FavoriteMealsNotifier() : super([]);

  // Toggles a meal's favorite status.
  // Returns true if the meal was added, or false if it was removed.
  bool toggleMealFavoriteStatus(Meal meal) {
    final mealIsFavorite = state.contains(meal);

    if (mealIsFavorite) {
      // Remove meal by creating a new filtered list (immutable state update)
      state = state.where((m) => m.id != meal.id).toList();
      return false;
    } else {
      // Add meal by creating a new list with all previous items plus the new meal
      state = [...state, meal];
      return true;
    }
  }
}

// StateNotifierProvider that exposes the FavoriteMealsNotifier and its List<Meal> state.
// Widgets can watch this provider to get updates when favorites change.
final favoriteMealsProvider =
    StateNotifierProvider<FavoriteMealsNotifier, List<Meal>>((ref) {
  return FavoriteMealsNotifier();
});
