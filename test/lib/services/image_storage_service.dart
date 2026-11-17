import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/input_image_item.dart';

/// Container for images loaded from the input directory.
class LoadedInputImages {
  const LoadedInputImages({required this.baseImage, required this.hairstyles});

  /// The primary portrait photo ("base.jpg").
  final InputImageItem baseImage;

  /// The list of hairstyle reference images found in the input folder.
  final List<InputImageItem> hairstyles;
}

/// Service responsible for file system and asset bundle operations.
///
/// Handles:
/// - Reading base portrait and hairstyle options from `assets/ai_input`
///   (with fallback to bundled assets if filesystem access is unavailable).
/// - Writing newly generated images to `assets/ai_output`.
/// - MIME type detection and file extension mapping.
class ImageStorageService {
  const ImageStorageService();

  /// Maps a file path or name to its corresponding MIME type string.
  static String mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Maps a MIME type string to an appropriate file extension.
  static String extensionForMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }

  /// Loads input images for the try-on pipeline.
  ///
  /// Attempt 1: Direct File System Access (`assets/ai_input`)
  /// On desktop and mobile platforms with access to the local filesystem,
  /// this dynamically scans `assets/ai_input` for all compatible images,
  /// matching "base.*" as the base face and "hairstyle*" as hairstyle options.
  ///
  /// Attempt 2: Flutter Asset Bundle Fallback (`rootBundle`)
  /// When running on Flutter Web or when the directory is not found on disk,
  /// this falls back to loading the default bundled assets `base.jpg` and
  /// `hairstyle.jpg`.
  Future<LoadedInputImages> loadInputImages() async {
    InputImageItem? baseItem;
    final hairstyles = <InputImageItem>[];

    final inputDir = Directory('assets/ai_input');

    // On non-web platforms, attempt to dynamically discover files in assets/ai_input.
    if (!kIsWeb && await inputDir.exists()) {
      final entities = await inputDir.list().toList();
      entities.sort((a, b) => a.path.compareTo(b.path));

      for (final entity in entities) {
        if (entity is! File) continue;

        final fileName = entity.uri.pathSegments.last;
        final lower = fileName.toLowerCase();

        // Filter out non-image files
        if (!lower.endsWith('.jpg') &&
            !lower.endsWith('.jpeg') &&
            !lower.endsWith('.png') &&
            !lower.endsWith('.webp')) {
          continue;
        }

        final bytes = await entity.readAsBytes();
        final item = InputImageItem(
          name: fileName,
          bytes: bytes,
          mimeType: mimeTypeForPath(fileName),
        );

        if (lower == 'base.jpg' ||
            lower == 'base.jpeg' ||
            lower == 'base.png') {
          baseItem = item;
        } else if (lower.startsWith('hairstyle')) {
          hairstyles.add(item);
        }
      }
    }

    // Fallback: If base image was not loaded from disk, load from bundled assets.
    if (baseItem == null) {
      final data = await rootBundle.load('assets/ai_input/base.jpg');
      baseItem = InputImageItem(
        name: 'base.jpg',
        bytes: data.buffer.asUint8List(),
        mimeType: 'image/jpeg',
      );
    }

    // Fallback: If no hairstyles were discovered, load default bundled hairstyle.
    if (hairstyles.isEmpty) {
      final data = await rootBundle.load('assets/ai_input/hairstyle.jpg');
      hairstyles.add(
        InputImageItem(
          name: 'hairstyle.jpg',
          bytes: data.buffer.asUint8List(),
          mimeType: 'image/jpeg',
        ),
      );
    }

    return LoadedInputImages(baseImage: baseItem, hairstyles: hairstyles);
  }

  /// Saves the generated image bytes to `assets/ai_output`.
  ///
  /// Writes two files:
  /// 1. A unique timestamped file (`hairstyle_output_<timestamp>.<ext>`) to keep history.
  /// 2. An overwrite file (`output.<ext>`) holding the most recent generation result.
  ///
  /// Returns the file path of the saved timestamped image.
  Future<String> saveOutputImage(Uint8List bytes, String mimeType) async {
    final ext = extensionForMimeType(mimeType);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'hairstyle_output_$timestamp.$ext';

    final outputDir = Directory('assets/ai_output');
    await outputDir.create(recursive: true);

    // Save timestamped version for record keeping
    final outputFile = File('${outputDir.path}/$fileName');
    await outputFile.writeAsBytes(bytes, flush: true);

    // Save/overwrite the latest output file
    final latestFile = File('${outputDir.path}/output.$ext');
    await latestFile.writeAsBytes(bytes, flush: true);

    return outputFile.path;
  }
}
