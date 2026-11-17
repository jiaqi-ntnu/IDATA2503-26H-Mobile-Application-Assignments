import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/input_image_item.dart';
import '../services/gemini_api_service.dart';
import '../services/image_storage_service.dart';
import '../widgets/image_preview_card.dart';

/// The main interactive page for the Hairstyle Try-On application.
///
/// Coordinates:
/// 1. Entering or detecting the Gemini API key.
/// 2. Discovering and previewing the base portrait image and available hairstyle options.
/// 3. Communicating with [GeminiApiService] to request a new hairstyle image.
/// 4. Saving and displaying the generated image through [ImageStorageService].
class HairstyleTryOnPage extends StatefulWidget {
  const HairstyleTryOnPage({
    super.key,
    this.httpClient,
    this.apiService,
    this.storageService = const ImageStorageService(),
  });

  /// Optional custom HTTP client (useful for unit/widget tests and mock responses).
  final http.Client? httpClient;

  /// Optional injected API service instance.
  final GeminiApiService? apiService;

  /// Service handling asset discovery and file saving operations.
  final ImageStorageService storageService;

  @override
  State<HairstyleTryOnPage> createState() => _HairstyleTryOnPageState();
}

class _HairstyleTryOnPageState extends State<HairstyleTryOnPage> {
  late final TextEditingController _apiKeyController;
  late final GeminiApiService _apiService;
  late final ImageStorageService _storageService;

  // Input state
  InputImageItem? _baseImage;
  List<InputImageItem> _hairstyleImages = const [];
  InputImageItem? _selectedHairstyle;

  // Generation result state
  Uint8List? _outputImageBytes;
  String? _savedOutputPath;
  String? _statusMessage;
  String? _errorMessage;

  // Multi-turn session tracking
  // _previousInteractionId stores the conversation turn ID from Gemini,
  // allowing the next request to reference previous inputs.
  String? _previousInteractionId;
  bool _baseSentInSession = false;

  // UI loading indicators
  bool _isLoadingInputs = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();

    // Initialize API service, using injected service or client if provided
    _apiService =
        widget.apiService ?? GeminiApiService(httpClient: widget.httpClient);
    _storageService = widget.storageService;

    // Retrieve default API key if defined via --dart-define or system environment variables
    const dartDefineKey = String.fromEnvironment('GEMINI_API_KEY');
    final envKey = !kIsWeb
        ? (Platform.environment['GEMINI_API_KEY'] ?? '')
        : '';
    _apiKeyController = TextEditingController(
      text: dartDefineKey.isNotEmpty ? dartDefineKey : envKey,
    );

    // Initial asset load
    _loadInputImages();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  /// Loads base and hairstyle images from the storage service.
  ///
  /// Resets session context whenever inputs are reloaded so that
  /// a new base image will be fully re-sent on the next request.
  Future<void> _loadInputImages() async {
    setState(() {
      _isLoadingInputs = true;
      _errorMessage = null;
    });

    try {
      final loaded = await _storageService.loadInputImages();

      if (!mounted) return;
      setState(() {
        _baseImage = loaded.baseImage;
        _hairstyleImages = loaded.hairstyles;
        _selectedHairstyle = loaded.hairstyles.isNotEmpty
            ? loaded.hairstyles.first
            : null;
        _baseSentInSession = false;
        _previousInteractionId = null;
        _isLoadingInputs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingInputs = false;
        _errorMessage = 'Failed to load images from assets/ai_input: $e';
      });
    }
  }

  /// Triggers the hairstyle generation process through the Gemini API.
  Future<void> _generateHairstyleTryOn() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Please provide a GEMINI_API_KEY (via field above or environment variable).';
      });
      return;
    }

    final baseImage = _baseImage;
    final hairstyleImage = _selectedHairstyle;
    if (baseImage == null || hairstyleImage == null) {
      setState(() {
        _errorMessage = 'Missing base.jpg or hairstyle.jpg in assets/ai_input.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _statusMessage = 'Sending request to Gemini Interactions API...';
    });

    try {
      // If we already sent the base image during this session and have an interaction ID,
      // we can conduct a follow-up turn where only the new hairstyle is uploaded.
      final isFollowUpTurn =
          _baseSentInSession && _previousInteractionId != null;

      final result = await _apiService.generateHairstyleTryOn(
        apiKey: apiKey,
        baseImage: baseImage,
        hairstyleImage: hairstyleImage,
        previousInteractionId: _previousInteractionId,
        isFollowUpTurn: isFollowUpTurn,
      );

      // Save the generated image to assets/ai_output
      final savedPath = await _storageService.saveOutputImage(
        result.bytes,
        result.mimeType,
      );

      if (!mounted) return;
      setState(() {
        _outputImageBytes = result.bytes;
        _savedOutputPath = savedPath;
        _previousInteractionId = result.interactionId ?? _previousInteractionId;
        _baseSentInSession = true;
        _statusMessage = 'Saved output image to $savedPath';
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _statusMessage = null;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hairstyle Try-On Demo'),
        actions: [
          IconButton(
            onPressed: _isLoadingInputs || _isGenerating
                ? null
                : _loadInputImages,
            tooltip: 'Reload assets/ai_input',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API key input field
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'GEMINI_API_KEY',
                hintText: 'Enter your Gemini API key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Loading assets spinner or input preview cards
            if (_isLoadingInputs)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Base image preview card
                  Expanded(
                    child: ImagePreviewCard(
                      title: 'Input: ${_baseImage?.name ?? "base.jpg"}',
                      subtitle:
                          'assets/ai_input/${_baseImage?.name ?? "base.jpg"}',
                      bytes: _baseImage?.bytes,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Hairstyle preview card with optional dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ImagePreviewCard(
                          title:
                              'Hairstyle: ${_selectedHairstyle?.name ?? "hairstyle.jpg"}',
                          subtitle:
                              'assets/ai_input/${_selectedHairstyle?.name ?? "hairstyle.jpg"}',
                          bytes: _selectedHairstyle?.bytes,
                        ),
                        if (_hairstyleImages.length > 1) ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<InputImageItem>(
                            initialValue: _selectedHairstyle,
                            decoration: const InputDecoration(
                              labelText: 'Select Hairstyle Image',
                              border: OutlineInputBorder(),
                            ),
                            items: _hairstyleImages
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _isGenerating
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedHairstyle = value;
                                    });
                                  },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action button to start generation
              FilledButton.icon(
                onPressed: _isGenerating ? null : _generateHairstyleTryOn,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_fix_high),
                label: Text(
                  _isGenerating
                      ? 'Generating Hairstyle Try-On...'
                      : 'Generate & Save to assets/ai_output',
                ),
              ),
            ],

            // Success / status message banner
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            // Error message container
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Output preview card
            ImagePreviewCard(
              title: 'Output Image',
              subtitle:
                  _savedOutputPath ?? 'assets/ai_output/ (not generated yet)',
              bytes: _outputImageBytes,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}
