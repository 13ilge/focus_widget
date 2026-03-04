import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/ana_ekran.dart';

void main() {
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
