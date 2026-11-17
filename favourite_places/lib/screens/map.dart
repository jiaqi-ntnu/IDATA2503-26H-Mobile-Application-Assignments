// Full-screen Google map with two modes: picking a location by tapping the map,
// and displaying an existing location read-only.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:favorite_places/models/place.dart';

/// Google map screen. The [isSelecting] flag decides the behaviour:
/// * `true` - tapping the map moves the marker and the save action returns
///   the tapped [LatLng] to the caller via `Navigator.pop`.
/// * `false` - the map is read-only and only shows the given [location].
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    // Falls back to Google HQ so the camera always has a valid target.
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });

  /// Location the camera starts on, and the only marker shown in read-only
  /// mode.
  final PlaceLocation location;

  /// True while the user is picking a point; false shows the map read-only.
  final bool isSelecting;

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  /// Position last tapped by the user; null until the map is tapped.
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
          actions: [
            if (widget.isSelecting)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _pickedLocation == null
                    ? null
                    : () {
                        // Hand the chosen point back to the LocationInput widget.
                        Navigator.of(context).pop(_pickedLocation);
                      },
              ),
          ]),
      body: GoogleMap(
        // Taps are ignored in read-only mode so the marker cannot be moved.
        onTap: !widget.isSelecting
            ? null
            : (position) {
                setState(() {
                  _pickedLocation = position;
                });
              },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          zoom: 16,
        ),
        // While picking, no marker is shown until the user has tapped a spot.
        markers: (_pickedLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _pickedLocation ??
                      LatLng(
                        widget.location.latitude,
                        widget.location.longitude,
                      ),
                ),
              },
      ),
    );
  }
}
