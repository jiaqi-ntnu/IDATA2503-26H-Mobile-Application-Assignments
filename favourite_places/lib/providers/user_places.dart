// Riverpod state for the user's places. Keeps the list in memory for the UI and
// mirrors every change into a local SQLite database so it survives restarts.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favorite_places/models/place.dart';

/// Opens (and creates on first launch) the `places.db` database in the app's
/// database directory and returns the connection.
Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      // Only runs the first time the database file is created. The location is
      // flattened into separate lat/lng/address columns.
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}

/// Owns the list of saved places and all persistence around it.
///
/// Starts empty; [loadPlaces] fills the list from the database and [addPlace]
/// writes a new place both to the database and to the in-memory state.
class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  /// Reads every row of the `user_places` table, turns each row into a [Place]
  /// and replaces the current state with the result.
  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();

    state = places;
  }

  /// Saves a new place: copies the picked image into the app's documents
  /// directory, inserts a row into the database and prepends the place to the
  /// state so it appears first in the list.
  void addPlace(String title, File image, PlaceLocation location) async {
    // The image picker keeps photos in a temporary cache folder that the OS may
    // clear, so store our own copy next to the database instead.
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }
}

/// Exposes the notifier (via `.notifier`) and its current list of places to the
/// widget tree.
final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
