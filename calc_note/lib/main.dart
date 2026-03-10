import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart'; 

void main() {
  runApp(const CalcNoteApp());
}

class CalcNoteApp extends StatelessWidget {
  const CalcNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Note',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF4F8FB)),
      home: const CalculatorScreen(),
    );
  }
}