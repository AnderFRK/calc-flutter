import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../models/calc_row.dart';
import '../widgets/custom_keypad.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<CalcRow> _rows = [CalcRow()];
  double _grandTotal = 0.0;
  int _focusedIndex = 0;
  
  bool _isTextMode = false; 

  void _onKeyPressed(String key) {
    final controller = _rows[_focusedIndex].controller;
    setState(() {
      if (key == 'C') {
        controller.text = '';
      } else if (key == '⌫') {
        if (controller.text.isNotEmpty) {
          controller.text = controller.text.substring(0, controller.text.length - 1);
        }
      } else if (key == '↵') {
        // MAGIA 2: Si presiona la flecha, insertamos un "\n" (salto de línea)
        controller.text += '\n';
      } else if (key == '=') {
        if (_focusedIndex == _rows.length - 1 && controller.text.isNotEmpty) {
          _rows.add(CalcRow());
          _focusedIndex++;
        } else if (_focusedIndex < _rows.length - 1) {
          _focusedIndex++;
        }
      } else {
        controller.text += key;
      }
    });
    _calculateRow(_focusedIndex, controller.text);
  }

  void _calculateRow(int index, String expression) {
    if (index == _rows.length - 1 && expression.isNotEmpty) {
      setState(() { _rows.add(CalcRow()); });
    }

    if (expression.isEmpty) {
      _rows[index].resultText = '';
      _rows[index].resultValue = 0.0;
      _updateTotal();
      return;
    }

    try {
      String cleanExp = expression.replaceAll('x', '*');
      cleanExp = cleanExp.replaceAll(RegExp(r'[^0-9\+\-\*\/\(\)\.]'), '');
      if (cleanExp.isEmpty) throw Exception('Solo texto');

      Parser p = Parser();
      Expression exp = p.parse(cleanExp);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      setState(() {
        _rows[index].resultValue = eval;
        _rows[index].resultText = eval.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      });
    } catch (e) {
      setState(() {
        _rows[index].resultText = '';
        _rows[index].resultValue = 0.0;
      });
    }
    _updateTotal();
  }

  void _updateTotal() {
    double total = 0;
    for (var row in _rows) { total += row.resultValue; }
    setState(() { _grandTotal = total; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Multiusos', style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: const Color(0xFF4FA5F9),
        elevation: 0,
        actions: [
          if (_isTextMode)
            TextButton.icon(
              icon: const Icon(Icons.dialpad, color: Colors.white),
              label: const Text('123', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                setState(() {
                  _isTextMode = false;
                });
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(milliseconds: 100), () {
                  _rows[_focusedIndex].focusNode.requestFocus();
                });
              },
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (context, index) {
                bool isFocused = _focusedIndex == index; 
                
                return GestureDetector(
                  onTap: () {
                    setState(() { _focusedIndex = index; });
                    _rows[index].focusNode.requestFocus();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 50),
                    decoration: BoxDecoration(
                      color: isFocused ? Colors.blue.shade50 : Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.blue.shade100, width: 0.5)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 40,
                            alignment: Alignment.topRight, 
                            padding: const EdgeInsets.only(top: 14, right: 8),
                            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.blue.shade100, width: 1))),
                            child: Text('${index + 1}', style: TextStyle(color: isFocused ? Colors.blue.shade800 : const Color(0xFF1E88E5), fontSize: 18)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.blue.shade100, width: 1))),
                              child: TextField(
                                controller: _rows[index].controller,
                                focusNode: _rows[index].focusNode, 
                                readOnly: !_isTextMode, 
                                showCursor: isFocused,
                                maxLines: null, 
                                keyboardType: _isTextMode ? TextInputType.multiline : TextInputType.none, 
                                style: const TextStyle(fontSize: 20, color: Colors.black87),
                                decoration: const InputDecoration(
                                  border: InputBorder.none, 
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                onChanged: (value) => _calculateRow(index, value),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.bottomRight, 
                              padding: const EdgeInsets.only(right: 12, bottom: 14),
                              child: Text(_rows[index].resultText, style: const TextStyle(fontSize: 20, color: Colors.black87)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: const Color(0xFFBBE0F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Total:    ', style: TextStyle(fontSize: 22, color: Color(0xFF333333))),
                Text(
                  _grandTotal.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          if (!_isTextMode)
            CustomKeypad(
              onKeyPressed: _onKeyPressed,
              onSwitchToText: () {
                setState(() {
                  _isTextMode = true; 
                });
                _rows[_focusedIndex].focusNode.requestFocus(); 
              },
            ),
        ],
      ),
    );
  }
}