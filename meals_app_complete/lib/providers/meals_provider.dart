import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meals/data/dummy_data.dart';

// Basic Provider that provides an immutable list of all available dummy meals.
// Since the dummyMeals list never changes, a simple Provider is sufficient.
final mealsProvider = Provider((ref) {
  return dummyMeals;
});
