import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(MyCurrencyApp());
}

class MyCurrencyApp extends StatefulWidget {
  @override
  _MyCurrencyAppState createState() => _MyCurrencyAppState();
}

class _MyCurrencyAppState extends State<MyCurrencyApp> {
  bool isDarkTheme = true;

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Курс валют',
      theme: isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: HomeScreen(toggleTheme: toggleTheme, isDarkTheme: isDarkTheme),
    );
  }
}
