// Form field that resolves a location in one of two ways: the device's GPS or a
// point picked on the map. Both paths end in a reverse-geocoding request that
// turns the coordinates into a readable address before reporting to the parent.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favorite_places/screens/map.dart';
import 'package:favorite_places/models/place.dart';

/// Location picker used by the add-place form.
class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  /// Called once a location has been picked *and* reverse-geocoded.
  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  /// Location chosen so far; null while the user has not picked one.
  PlaceLocation? _pickedLocation;

  /// True while the GPS fix and address lookup are running, which shows a
  /// spinner in the preview box.
  var _isGettingLocation = false;

  /// Static Maps URL previewing the picked point, or an empty string when no
  /// location has been picked yet.
  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDLcwxUggpPZo8lcbH0TB4Crq5SJjtj4ag';
  }

  /// Reverse-geocodes [latitude]/[longitude] into a street address, stores the
  /// result as the picked location and reports it to the parent widget.
  Future<void> _savePlace(double latitude, double longitude) async {
    // Google's Geocoding API turns coordinates into a postal address.

    var address =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    try {
      const channel = MethodChannel('favorite_places/maps_config');
      final apiKey = await channel.invokeMethod<String>('getApiKey');
      if (apiKey == null || apiKey.isEmpty) {
        throw StateError('Maps key is missing');
      }
      final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '$latitude,$longitude',
        'key': apiKey,
      });
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'];
      if (response.statusCode == 200 &&
          data['status'] == 'OK' &&
          results is List &&
          results.isNotEmpty &&
          results.first['formatted_address'] is String) {
        address = results.first['formatted_address'] as String;
      }
    } catch (_) {
      // Coordinates remain usable when the address service is unavailable.
    }

    if (!mounted) return;

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  /// Asks for location services and permission if needed, reads the current
  /// position and forwards it to [_savePlace] for reverse geocoding.
  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);
    try {
      const channel = MethodChannel('favorite_places/maps_config');
      final apiKey = await channel.invokeMethod<String>('getApiKey');
      if (apiKey == null || apiKey.isEmpty) {
        throw StateError('Maps key is missing');
      }
      final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '$latitude,$longitude',
        'key': apiKey,
      });
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      // GPS may be switched off entirely, so ask the user to enable it and give
      // up if they decline.
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showError('Please enable location services.');
          return;
        }
      }

      // Same for the runtime permission: stop quietly if it is refused.
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      }
      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        _showError(
            'Location permission is required. Enable it in app settings.');
        return;
      }

      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      // Coordinates can be missing when no position fix was obtained.
      if (lat == null || lng == null) {
        _showError('Could not determine your location. Please try again.');
        return;
      }

      await _savePlace(lat, lng);
    } catch (_) {
      _showError(
          'Could not get your location. Check location services and try again.');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Opens the map in selecting mode and reverse-geocodes the tapped point.
  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );

    // Popping without the save button returns null: nothing was picked.
    if (!mounted || pickedLocation == null) {
      return;
    }

    setState(() => _isGettingLocation = true);
    await _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    // Preview area keeps its size while switching between placeholder text, the
    // static map image and the loading spinner.
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(_pickedLocation!.address, textAlign: TextAlign.center),
        ),
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        // The two ways to obtain coordinates: GPS or a point on the map.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _isGettingLocation ? null : _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}
