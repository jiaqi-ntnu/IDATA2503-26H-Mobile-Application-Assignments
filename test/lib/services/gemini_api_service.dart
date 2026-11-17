import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/input_image_item.dart';

/// Holds the output returned by the Gemini image generation API.
class GeneratedImageResult {
  const GeneratedImageResult({
    required this.bytes,
    required this.mimeType,
    this.interactionId,
  });

  /// The decoded image binary data.
  final Uint8List bytes;

  /// The MIME type of the returned image (e.g. `image/png` or `image/jpeg`).
  final String mimeType;

  /// Optional interaction ID returned by Gemini, used to chain multi-turn sessions.
  final String? interactionId;
}

/// Service dedicated to handling interactions with the Google Gemini API.
///
/// This service formats multi-modal requests (text + base64 image data),
/// manages multi-turn conversational context using `previous_interaction_id`,
/// posts data to the Generative Language Interactions endpoint, and parses
/// returned image outputs.
class GeminiApiService {
  GeminiApiService({this.httpClient});

  /// Optional injected HTTP client for testing or custom networking configurations.
  final http.Client? httpClient;

  /// Base URL endpoint for Google Generative Language Interactions API.
  static const String _apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/interactions';

  /// The target Gemini model configured for multi-modal image manipulation.
  static const String _modelName = 'models/gemini-nano-banana-2.1';

  /// System instructions defining Gemini's persona and constraints.
  ///
  /// Key rules enforced:
  /// - Base image represents the person's face structure, which must be strictly preserved.
  /// - Only the hairstyle should be modified according to the selected hairstyle image.
  /// - Subsequent interaction turns receive new hairstyles to be applied to the initial base face.
  static const String systemInstruction =
      'You are responsible for an app called Hairstyle try-on.'
      'Users will take a image of themselves titled "base.jpg", and they will '
      'select a hairstyle they want to see on themselves: this selected '
      'hairstyle will be titled hairstyle.jpg. You will generate a image as '
      'accurately and as realistic as possible of how the user will look if '
      'they had this selected hairstyle. DO NOT change anything other than '
      'the hairstyle -- make sure to preserve the face structure, shape, '
      'features, proportions and details exactly as it is.\n\n'
      'After the initial prompt, the future prompts will only be of new '
      'hairstyles, titled hairstyle_*.jpg. where * can be anything. Apply '
      'these new hairstyles on the last fed base.jpg. If a new base.jpg has '
      'been uploaded this will be the new base to work with';

  /// Sends a request to Gemini to generate an image combining [baseImage] and [hairstyleImage].
  ///
  /// - [apiKey]: The Google Gemini API key used for authentication via query parameter.
  /// - [baseImage]: The primary photo of the user's face ("base.jpg").
  /// - [hairstyleImage]: The target hairstyle photo to apply.
  /// - [previousInteractionId]: If continuing an existing session, provides the ID
  ///   from the previous call so the model maintains conversational state.
  /// - [isFollowUpTurn]: When true, avoids re-uploading the base image bytes and
  ///   instructs Gemini to reuse the base image from the active session.
  ///
  /// Returns a [GeneratedImageResult] containing the generated image bytes, mime type,
  /// and updated interaction ID.
  Future<GeneratedImageResult> generateHairstyleTryOn({
    required String apiKey,
    required InputImageItem baseImage,
    required InputImageItem hairstyleImage,
    String? previousInteractionId,
    bool isFollowUpTurn = false,
  }) async {
    // Determine whether to use the injected client or instantiate an ephemeral one.
    final client = httpClient ?? http.Client();
    final shouldCloseClient = httpClient == null;

    try {
      // Build the multi-modal input payload.
      // - First turn: Upload base image + hairstyle image + prompt.
      // - Follow-up turn: Upload only the new hairstyle image + follow-up prompt,
      //   linking to the previous turn via `previous_interaction_id`.
      final inputBlocks = <Map<String, dynamic>>[
        if (!isFollowUpTurn) ...[
          {'type': 'text', 'text': baseImage.name},
          {
            'type': 'image',
            'mime_type': baseImage.mimeType,
            'data': base64Encode(baseImage.bytes),
          },
        ],
        {'type': 'text', 'text': hairstyleImage.name},
        {
          'type': 'image',
          'mime_type': hairstyleImage.mimeType,
          'data': base64Encode(hairstyleImage.bytes),
        },
        {
          'type': 'text',
          'text': isFollowUpTurn
              ? 'Apply this new hairstyle (${hairstyleImage.name}) on the last fed base.jpg.'
              : 'Generate an image of the person in ${baseImage.name} with the hairstyle from ${hairstyleImage.name}.',
        },
      ];

      // Assemble full JSON request payload adhering to the Gemini Interactions API schema.
      final requestPayload = <String, dynamic>{
        'model': _modelName,
        'input': inputBlocks,
        'system_instruction': systemInstruction,
        if (isFollowUpTurn && previousInteractionId != null)
          'previous_interaction_id': previousInteractionId,
        'tools': [
          {'type': 'google_search'},
        ],
        'generation_config': {
          'max_output_tokens': 65536,
          'thinking_level': 'medium',
          'image_config': {'aspect_ratio': '1:1', 'image_size': '1K'},
        },
        'response_modalities': ['image'],
      };

      // Authenticate via the 'key' query parameter on the endpoint URI.
      final uri = Uri.parse(_apiEndpoint)
          .replace(queryParameters: {'key': apiKey});

      // Perform POST request to Gemini.
      final response = await client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      // Verify that the HTTP response code indicates success.
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.body}',
          uri: uri,
        );
      }

      // Parse the JSON response.
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final interactionId = decoded['id'] as String?;
      final extracted = _extractImageFromResponse(decoded);

      if (extracted == null) {
        throw StateError('No image returned in response: ${response.body}');
      }

      return GeneratedImageResult(
        bytes: extracted.bytes,
        mimeType: extracted.mimeType,
        interactionId: interactionId ?? previousInteractionId,
      );
    } finally {
      // Ensure ephemeral client is cleanly closed.
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Traverses multiple candidate locations in the Gemini response JSON to extract image bytes.
  ///
  /// Gemini responses can store multi-modal outputs in different structures depending on
  /// the execution pathway:
  /// 1. `outputs` list (direct output blocks)
  /// 2. `steps` list (thought process or intermediate step content)
  /// 3. `candidates` list (content parts matching standard Gemini chat structure)
  ///
  /// Each block may contain base64 image data under either:
  /// - `{'type': 'image', 'data': '<base64>'}`
  /// - `{'inline_data': {'data': '<base64>'}}` or camelCase `inlineData`
  ({Uint8List bytes, String mimeType})? _extractImageFromResponse(
    Map<String, dynamic> responseJson,
  ) {
    final contentCandidates = <dynamic>[];

    // Collect blocks from `outputs`
    if (responseJson['outputs'] is List) {
      contentCandidates.addAll(responseJson['outputs'] as List);
    }

    // Collect blocks from `steps`
    if (responseJson['steps'] is List) {
      for (final step in responseJson['steps'] as List) {
        if (step is Map<String, dynamic> && step['content'] is List) {
          contentCandidates.addAll(step['content'] as List);
        }
      }
    }

    // Collect blocks from `candidates`
    if (responseJson['candidates'] is List) {
      for (final candidate in responseJson['candidates'] as List) {
        if (candidate is Map<String, dynamic>) {
          final content = candidate['content'];
          if (content is Map<String, dynamic> && content['parts'] is List) {
            contentCandidates.addAll(content['parts'] as List);
          }
        }
      }
    }

    // Scan all candidate blocks for base64 image data
    for (final item in contentCandidates) {
      if (item is! Map<String, dynamic>) continue;

      // Format 1: Direct 'image' type block
      if (item['type'] == 'image' && item['data'] is String) {
        final mimeType = (item['mime_type'] as String?) ?? 'image/png';
        return (
          bytes: base64Decode(item['data'] as String),
          mimeType: mimeType,
        );
      }

      // Format 2: Nested inline_data block
      final inlineData = item['inline_data'] ?? item['inlineData'];
      if (inlineData is Map<String, dynamic> && inlineData['data'] is String) {
        final mimeType =
            (inlineData['mime_type'] ?? inlineData['mimeType']) as String? ??
            'image/png';
        return (
          bytes: base64Decode(inlineData['data'] as String),
          mimeType: mimeType,
        );
      }
    }

    return null;
  }
}
