import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/translation_provider.dart';
import 'package:frontend/widgets/file_upload_widget.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLanguage = 'english';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Comic Auto Translator Reader'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<TranslationProvider>(
        builder: (context, provider, _) {
          if (provider.state == UploadState.completed &&
              provider.currentResult != null) {
            return ResultsScreen(
              result: provider.currentResult!,
              onReset: () => provider.reset(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extract Text from Manga Images',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload an image to run the current OCR MVP backend and inspect the extracted text blocks.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                FileUploadWidget(
                  isLoading: provider.state == UploadState.uploading,
                  onFileSelected: (filePath) {
                    provider.uploadFile(
                      filePath,
                      language: _selectedLanguage,
                    );
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  'Target Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'english',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'spanish',
                        child: Text('Spanish'),
                      ),
                      DropdownMenuItem(
                        value: 'french',
                        child: Text('French'),
                      ),
                      DropdownMenuItem(
                        value: 'german',
                        child: Text('German'),
                      ),
                      DropdownMenuItem(
                        value: 'portuguese',
                        child: Text('Portuguese'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null &&
                          provider.state == UploadState.initial) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),

                if (provider.state == UploadState.uploading) ...[
                  _buildStatusWidget(
                    context,
                    'Uploading image and running OCR...',
                    Colors.blue,
                    LinearProgressIndicator(value: provider.uploadProgress),
                  ),
                ] else if (provider.state == UploadState.error) ...[
                  _buildErrorWidget(context, provider.errorMessage),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => provider.reset(),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusWidget(
    BuildContext context,
    String message,
    Color color,
    Widget progressWidget,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          progressWidget,
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String? errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'OCR Request Failed',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'An unknown error occurred',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
