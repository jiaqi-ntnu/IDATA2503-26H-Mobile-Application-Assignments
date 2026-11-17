import 'package:flutter/foundation.dart';

/// Represents an image loaded as input for the hairstyle try-on pipeline.
///
/// Holds the image's file [name] (used for identification and prompt references),
/// the raw [bytes] for display and encoding, and the detected [mimeType] (such
/// as `image/jpeg` or `image/png`) required by the Gemini API.
class InputImageItem {
  const InputImageItem({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  /// The filename of the image (e.g., "base.jpg", "hairstyle.jpg").
  final String name;

  /// Raw binary data of the image.
  final Uint8List bytes;

  /// MIME type string used when sending image payloads to the API.
  final String mimeType;
}
