// Home screen: loads the saved places once on first build, shows a spinner
// while that read is running and then renders the list. The app bar action
// opens the "add place" form.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/screens/add_place.dart';
import 'package:favorite_places/widgets/places_list.dart';
import 'package:favorite_places/providers/user_places.dart';

/// Overview of all saved places, and the entry point for adding a new one.
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() {
    return _PlacesScreenState();
  }
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  /// Result of the initial database read; the FutureBuilder below waits on it.
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    // Load once on startup. `read` (rather than `watch`) keeps this from being
    // re-triggered every time the provider's state changes.
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds this screen whenever the list of places changes.
    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // The form closes itself again once the place has been saved.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddPlaceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // Spinner until the places have been read, then the list itself.
        child: FutureBuilder(
          future: _placesFuture,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : PlacesList(
                      places: userPlaces,
                    ),
        ),
      ),
    );
  }
}
