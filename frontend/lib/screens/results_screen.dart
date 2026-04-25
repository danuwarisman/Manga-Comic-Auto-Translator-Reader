import 'package:flutter/material.dart';
import 'package:frontend/models/translation_model.dart';

class ResultsScreen extends StatefulWidget {
  final TranslationResult result;
  final VoidCallback onReset;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.onReset,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _currentPageIndex = 0;
  bool _showTranslated = true;

  @override
  Widget build(BuildContext context) {
    final pages = widget.result.pages;

    if (pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('OCR Results'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onReset,
          ),
        ),
        body: const Center(
          child: Text('No OCR pages available'),
        ),
      );
    }

    final currentPage = pages[_currentPageIndex];
    final hasOriginalImage = currentPage.originalImageUrl.isNotEmpty;
    final hasTranslatedImage = currentPage.translatedImageUrl.isNotEmpty;
    final canToggleImages = hasOriginalImage && hasTranslatedImage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.result.fileName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onReset,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'OCR Complete • ${pages.length} page(s) • Target: ${widget.result.targetLanguage}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page ${_currentPageIndex + 1} of ${pages.length}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildImagePlaceholder(
                      label: _showTranslated ? 'Translated Preview' : 'Original Preview',
                      message:
                          'Image preview is not available in the current MVP backend response.',
                    ),
                    const SizedBox(height: 16),
                    if (canToggleImages) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Original'),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('Translated'),
                              ),
                            ],
                            selected: {_showTranslated},
                            onSelectionChanged: (Set<bool> newSelection) {
                              setState(() {
                                _showTranslated = newSelection.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!canToggleImages) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Current backend MVP only returns OCR text blocks. Image preview and translated images are not generated yet.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (currentPage.textBlocks.isNotEmpty) ...[
                      Text(
                        'Detected Text Blocks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildTextBlocks(currentPage.textBlocks),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Text('No text blocks were returned by OCR.'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentPageIndex > 0
                      ? () {
                          setState(() {
                            _currentPageIndex--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                Text(
                  '${_currentPageIndex + 1} / ${pages.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _currentPageIndex < pages.length - 1
                      ? () {
                          setState(() {
                            _currentPageIndex++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({
    required String label,
    required String message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTextBlocks(List<TextBlock> blocks) {
    return blocks.map((block) {
      final translatedText = block.translatedText.trim().isEmpty
          ? 'Translation not available in current MVP.'
          : block.translatedText;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Original:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Confidence: ${(block.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              block.originalText.isEmpty ? '(empty result)' : block.originalText,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            const Text(
              'Translated:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              translatedText,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
