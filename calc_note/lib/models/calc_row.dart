import 'package:flutter/material.dart';
import '../utils/math_controller.dart';

class CalcRow {
  MathTextController controller = MathTextController(); 
  FocusNode focusNode = FocusNode(); 
  String resultText = '';
  double resultValue = 0.0;
}