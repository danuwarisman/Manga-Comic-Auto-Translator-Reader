import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileUploadWidget extends StatefulWidget {
  final Function(String filePath) onFileSelected;
  final bool isLoading;

  const FileUploadWidget({
    super.key,
    required this.onFileSelected,
    this.isLoading = false,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? _selectedFileName;

  Future<void> _pickFile() async {
    if (widget.isLoading) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
        });
        widget.onFileSelected(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.isLoading ? null : _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isLoading ? Colors.grey : Colors.blue,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: widget.isLoading ? Colors.grey[100] : Colors.blue[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: widget.isLoading ? Colors.grey : Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Manga Image',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: widget.isLoading ? Colors.grey : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported in current MVP: JPG, JPEG, PNG, WEBP',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (_selectedFileName != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selected: $_selectedFileName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
