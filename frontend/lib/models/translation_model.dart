class TranslationResult {
  final String fileName;
  final String status;
  final String targetLanguage;
  final List<TranslatedPage> pages;
  final DateTime createdAt;
  final List<OcrTextResult> texts;

  TranslationResult({
    required this.fileName,
    required this.status,
    required this.targetLanguage,
    required this.pages,
    required this.createdAt,
    required this.texts,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    return TranslationResult(
      fileName: json['file_name'] ?? '',
      status: json['status'] ?? 'pending',
      targetLanguage: json['target_language'] ?? 'english',
      pages: (json['pages'] as List?)
              ?.map((page) => TranslatedPage.fromJson(page))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      texts: (json['texts'] as List?)
              ?.map((item) => OcrTextResult.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'status': status,
        'target_language': targetLanguage,
        'pages': pages.map((p) => p.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'texts': texts.map((t) => t.toJson()).toList(),
      };
}

class TranslatedPage {
  final int pageNumber;
  final String originalImageUrl;
  final String translatedImageUrl;
  final List<TextBlock> textBlocks;
  final String status;

  TranslatedPage({
    required this.pageNumber,
    required this.originalImageUrl,
    required this.translatedImageUrl,
    required this.textBlocks,
    required this.status,
  });

  factory TranslatedPage.fromJson(Map<String, dynamic> json) {
    return TranslatedPage(
      pageNumber: json['page_number'] ?? 0,
      originalImageUrl: json['original_image_url'] ?? '',
      translatedImageUrl: json['translated_image_url'] ?? '',
      textBlocks: (json['text_blocks'] as List?)
              ?.map((block) => TextBlock.fromJson(block))
              .toList() ??
          [],
      status: json['status'] ?? 'processing',
    );
  }

  Map<String, dynamic> toJson() => {
        'page_number': pageNumber,
        'original_image_url': originalImageUrl,
        'translated_image_url': translatedImageUrl,
        'text_blocks': textBlocks.map((b) => b.toJson()).toList(),
        'status': status,
      };
}

class TextBlock {
  final String originalText;
  final String translatedText;
  final double confidence;

  TextBlock({
    required this.originalText,
    required this.translatedText,
    required this.confidence,
  });

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(
      originalText: json['original_text'] ?? '',
      translatedText: json['translated_text'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'original_text': originalText,
        'translated_text': translatedText,
        'confidence': confidence,
      };
}

class OcrTextResult {
  final String text;
  final dynamic bbox;
  final double? confidence;

  OcrTextResult({
    required this.text,
    required this.bbox,
    required this.confidence,
  });

  factory OcrTextResult.fromJson(Map<String, dynamic> json) {
    return OcrTextResult(
      text: json['text'] ?? '',
      bbox: json['bbox'],
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'bbox': bbox,
        'confidence': confidence,
      };
}
