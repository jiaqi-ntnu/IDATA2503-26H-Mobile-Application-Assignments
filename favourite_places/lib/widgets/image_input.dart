// Reusable form field for capturing a photo with the device camera. It shows a
// "Take Picture" button until an image exists, then a tappable preview that
// lets the user retake the photo.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Camera input widget. The captured file is reported to the parent through
/// [onPickImage], which is called again whenever the photo is retaken.
class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  /// Called with the image file right after a picture has been taken.
  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  /// Photo taken so far; null until the first picture is captured.
  File? _selectedImage;

  /// Opens the camera, keeps the result as a local [File] and notifies the
  /// parent widget.
  void _takePicture() async {
    final imagePicker = ImagePicker();
    // `maxWidth` downscales the photo before it is saved, which keeps the files
    // on disk small.
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    // The user cancelled the camera, so keep whatever image was there before.
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    // Default state: a button that opens the camera.
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: const Text('Take Picture'),
      onPressed: _takePicture,
    );

    // Once a photo exists, the preview itself becomes the retake button.
    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Fixed-height bordered box that reserves space for either the button or
    // the preview.
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
