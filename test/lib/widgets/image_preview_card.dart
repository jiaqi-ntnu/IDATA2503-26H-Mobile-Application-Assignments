import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A reusable card widget that displays an image preview alongside a title and subtitle.
///
/// If [bytes] is provided, renders the image using [Image.memory].
/// If [bytes] is null, renders a styled placeholder box indicating "No image".
class ImagePreviewCard extends StatelessWidget {
  const ImagePreviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bytes,
    this.height = 220,
  });

  /// The header title displayed at the top of the card.
  final String title;

  /// Subtitle detailing additional info (e.g. file path or status).
  final String subtitle;

  /// The raw image bytes to render. When null, a fallback placeholder is shown.
  final Uint8List? bytes;

  /// The fixed height of the image preview container.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title label
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),

            // Subtitle path or status
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),

            // Image display area or placeholder
            SizedBox(
              height: height,
              width: double.infinity,
              child: bytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(bytes!, fit: BoxFit.contain),
                    )
                  : Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('No image'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
