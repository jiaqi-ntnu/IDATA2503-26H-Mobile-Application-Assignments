// Data model for a favourite place and its location. Both classes are plain
// immutable value objects; persistence lives in the provider layer.

import 'dart:io';

import 'package:uuid/uuid.dart';

// Shared UUID generator, used to give every newly created place a unique id.
const uuid = Uuid();

/// Coordinates of a place plus the human readable address belonging to them.
class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;

  /// Reverse-geocoded address, e.g. "Karl Johans gate 1, Oslo".
  final String address;
}

/// A single favourite place: a title, a picture and a location.
///
/// When [id] is omitted a random UUID is generated. Existing ids are passed in
/// when places are rebuilt from database rows so they stay stable.
class Place {
  Place({
    required this.title,
    required this.image,
    required this.location,
    String? id,
  }) : id = id ?? uuid.v4();

  /// Unique identifier, also used as the primary key in the database.
  final String id;
  final String title;

  /// The image stored in the app's documents directory, not the temporary file
  /// handed over by the image picker.
  final File image;
  final PlaceLocation location;
}
