import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/translation_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(
            // Update this URL based on your backend configuration
            baseUrl: 'http://localhost:8000',
          ),
        ),
        ChangeNotifierProvider<TranslationProvider>(
          create: (context) => TranslationProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Manga Comic Auto Translator Reader',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

