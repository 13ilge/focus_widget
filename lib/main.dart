import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/ana_ekran.dart';
import 'services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidgetService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zinciri Kırma',
      theme: AppTheme.darkTheme,
      home: const AnaEkran(),
    );
  }
}
