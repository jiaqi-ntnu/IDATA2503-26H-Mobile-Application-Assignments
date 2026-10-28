import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meals/providers/meals_provider.dart';

// Available dietary filter keys.
enum Filter {
  glutenFree,
  lactoseFree,
  vegetarian,
  vegan,
}

// StateNotifier managing the user's active dietary filters.
// Tracks a Map of each Filter enum to a boolean indicating if it is enabled.
class FiltersNotifier extends StateNotifier<Map<Filter, bool>> {
  FiltersNotifier()
      : super({
          Filter.glutenFree: false,
          Filter.lactoseFree: false,
          Filter.vegetarian: false,
          Filter.vegan: false
        });

  // Replaces all filter settings at once.
  void setFilters(Map<Filter, bool> chosenFilters) {
    state = chosenFilters;
  }

  // Updates a single filter by producing a new immutable map copy.
  void setFilter(Filter filter, bool isActive) {
    // Direct mutation like `state[filter] = isActive` does not notify listeners;
    // creating a new map triggers state updates in Riverpod.
    state = {
      ...state,
      filter: isActive,
    };
  }
}

// Provider exposing the active filter states and methods to toggle them.
final filtersProvider =
    StateNotifierProvider<FiltersNotifier, Map<Filter, bool>>(
  (ref) => FiltersNotifier(),
);

// Derived (computed) Provider that filters the master meals list based on active filters.
// Automatically recomputes whenever either `mealsProvider` or `filtersProvider` changes.
final filteredMealsProvider = Provider((ref) {
  final meals = ref.watch(mealsProvider);
  final activeFilters = ref.watch(filtersProvider);

  return meals.where((meal) {
    // If a filter is enabled and the meal does not satisfy it, exclude the meal.
    if (activeFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
      return false;
    }
    if (activeFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
      return false;
    }
    if (activeFilters[Filter.vegetarian]! && !meal.isVegetarian) {
      return false;
    }
    if (activeFilters[Filter.vegan]! && !meal.isVegan) {
      return false;
    }
    return true; // Meal matches all active filter criteria
  }).toList();
});
