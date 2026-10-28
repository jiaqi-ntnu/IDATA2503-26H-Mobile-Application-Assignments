// Enum indicating the preparation difficulty of a meal.
enum Complexity {
  simple,
  challenging,
  hard,
}

// Enum indicating the cost level of a meal.
enum Affordability {
  affordable,
  pricey,
  luxurious,
}

// Data model representing a recipe/meal with its metadata, ingredients, steps, and dietary flags.
class Meal {
  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.isVegan,
    required this.isVegetarian,
  });

  final String id;
  // Category IDs to which this meal belongs.
  final List<String> categories;
  final String title;
  // Remote web URL for the meal image.
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  // Preparation and cooking duration in minutes.
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  // Dietary filter flags
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isVegan;
  final bool isVegetarian;
}
