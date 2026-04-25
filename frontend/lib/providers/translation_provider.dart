import 'package:flutter/foundation.dart';
import 'package:frontend/models/translation_model.dart';
import 'package:frontend/services/api_service.dart';

enum UploadState { initial, uploading, completed, error }

class TranslationProvider extends ChangeNotifier {
  final ApiService apiService;

  TranslationProvider({required this.apiService});

  UploadState _state = UploadState.initial;
  TranslationResult? _currentResult;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  UploadState get state => _state;
  TranslationResult? get currentResult => _currentResult;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  Future<void> uploadFile(String filePath, {String language = 'english'}) async {
    _state = UploadState.uploading;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final result = await apiService.uploadFile(filePath, language: language);
      _currentResult = result;
      _uploadProgress = 1.0;
      _state = UploadState.completed;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = UploadState.error;
      notifyListeners();
    }
  }

  void reset() {
    _state = UploadState.initial;
    _currentResult = null;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
