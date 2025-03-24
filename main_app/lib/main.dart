import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'flood_page.dart';
import 'selection.dart';
import 'theme.dart';
import 'imagecolrisation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Analysis & Flood Detection',
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButtonStyle,
        ),
      ),
      home: SelectionPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/flood': (context) => const FloodScreen(),
        '/selection': (context) => SelectionPage(),
        '/sar': (context) => const SARColorizationScreen(),
      },
    );
  }
}
