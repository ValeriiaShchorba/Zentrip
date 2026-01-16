import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/language/language_provider.dart';
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
      child: const ZentripApp(),
    ),
  );
}

class ZentripApp extends StatelessWidget {
  const ZentripApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zentrip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}
