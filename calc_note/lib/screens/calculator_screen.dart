import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calc_row.dart';
import '../widgets/custom_keypad.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<CalcRow> _rows = [];
  double _grandTotal = 0.0;
  int _focusedIndex = 0;
  bool _isTextMode = false; 

  // --- VARIABLES PARA EL TÍTULO ---
  String _currentFileName = "Nota Nueva";
  bool _isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  // --- SISTEMA DE GUARDADO ---
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    _currentFileName = prefs.getString('last_file_name') ?? "Nota Nueva";
    _titleController.text = _currentFileName;

    List<String>? savedText = prefs.getStringList('calc_data_$_currentFileName');

    setState(() {
      _rows.clear();
      if (savedText != null && savedText.isNotEmpty) {
        for (String text in savedText) {
          CalcRow row = CalcRow();
          row.controller.text = text;
          _rows.add(row);
        }
      } else {
        _rows.add(CalcRow()); 
      }
    });

    for (int i = 0; i < _rows.length; i++) {
      _calculateRow(i, _rows[i].controller.text);
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_file_name', _currentFileName);
    List<String> dataToSave = _rows.map((row) => row.controller.text).toList();
    await prefs.setStringList('calc_data_$_currentFileName', dataToSave);
  }

  void _crearArchivoNuevo() {
    setState(() {
      _currentFileName = "Nota Nueva";
      _titleController.text = _currentFileName;
      _rows.clear();
      _rows.add(CalcRow());
      _grandTotal = 0.0;
      _focusedIndex = 0;
    });
    _saveData();
    Navigator.pop(context); 
  }

  // --- LÓGICA DE TECLADO INTELIGENTE (RESPETA EL CURSOR) ---
  void _onKeyPressed(String key) {
    if (_rows.isEmpty) return;
    final controller = _rows[_focusedIndex].controller;
    
    // Obtenemos en qué posición exacta está la barrita del cursor
    int cursorPos = controller.selection.baseOffset;
    if (cursorPos < 0) cursorPos = controller.text.length; // Si no hay cursor, asumimos el final

    setState(() {
      if (key == 'C') {
        controller.text = '';
      } else if (key == '⌫') {
        // Borra justo lo que está antes del cursor
        if (controller.text.isNotEmpty && cursorPos > 0) {
          String text = controller.text;
          controller.text = text.substring(0, cursorPos - 1) + text.substring(cursorPos);
          controller.selection = TextSelection.collapsed(offset: cursorPos - 1);
        }
      } else if (key == '↵' || key == '=') {
        if (_focusedIndex == _rows.length - 1 && controller.text.isNotEmpty) {
          _rows.add(CalcRow());
          _focusedIndex++;
        } else if (_focusedIndex < _rows.length - 1) {
          _focusedIndex++;
        }
      } else {
        // Escribe el número justo donde pusiste el cursor
        String text = controller.text;
        controller.text = text.substring(0, cursorPos) + key + text.substring(cursorPos);
        controller.selection = TextSelection.collapsed(offset: cursorPos + key.length);
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
      _saveData(); 
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
    _saveData(); 
  }

  void _updateTotal() {
    double total = 0;
    for (var row in _rows) { total += row.resultValue; }
    setState(() { _grandTotal = total; });
  }

  @override
  Widget build(BuildContext context) {
    bool isNativeKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF3399FF)),
              child: Text('CalcNote', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Archivo nuevo'),
              onTap: _crearArchivoNuevo,
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Guardar (Manual)'),
              onTap: () {
                _saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Buscar en Archivos'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), 
        title: _isEditingTitle 
          ? TextField(
              controller: _titleController,
              autofocus: true, 
              style: const TextStyle(color: Colors.white, fontSize: 20),
              cursorColor: Colors.white,
              decoration: const InputDecoration(border: InputBorder.none),
              onSubmitted: (val) {
                setState(() {
                  _currentFileName = val.isNotEmpty ? val : "Nota Nueva";
                  _isEditingTitle = false;
                });
                _saveData(); 
              },
            )
          : GestureDetector(
              onTap: () => setState(() => _isEditingTitle = true),
              child: Row(
                children: [
                  Text(_currentFileName, style: const TextStyle(color: Colors.white, fontSize: 22)),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: Colors.white70, size: 18), 
                ],
              ),
            ),
        backgroundColor: const Color(0xFF3399FF),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buscador en desarrollo...')));
          }),
          IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _crearArchivoNuevo),
          IconButton(icon: const Icon(Icons.save, color: Colors.white), onPressed: _saveData),
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
                    constraints: const BoxConstraints(minHeight: 45),
                    decoration: BoxDecoration(
                      color: isFocused ? Colors.blue.shade50 : Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.blue.shade100, width: 0.5)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 35,
                            alignment: Alignment.topRight, 
                            padding: const EdgeInsets.only(top: 12, right: 8),
                            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.blue.shade100, width: 1))),
                            child: Text('${index + 1}', style: TextStyle(color: isFocused ? Colors.blue.shade800 : const Color(0xFF1E88E5), fontSize: 16)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.blue.shade100, width: 1))),
                              // SOLUCIÓN AL TOQUE: Le ponemos el onTap directo al TextField
                              child: TextField(
                                controller: _rows[index].controller,
                                focusNode: _rows[index].focusNode, 
                                readOnly: !_isTextMode, 
                                showCursor: isFocused,
                                maxLines: null, 
                                keyboardType: _isTextMode ? TextInputType.multiline : TextInputType.none, 
                                style: const TextStyle(fontSize: 18, color: Colors.black87),
                                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10)),
                                onTap: () {
                                  setState(() { _focusedIndex = index; });
                                },
                                onChanged: (value) => _calculateRow(index, value),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.bottomRight, 
                              padding: const EdgeInsets.only(right: 12, bottom: 12),
                              child: Text(_rows[index].resultText, style: const TextStyle(fontSize: 18, color: Colors.black87)),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: const Color(0xFFB3D9FF), 
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() { _isTextMode = false; });
                    FocusScope.of(context).unfocus(); 
                    if (_rows.isNotEmpty) _rows[_focusedIndex].focusNode.requestFocus();
                  },
                  child: Text('123', style: TextStyle(fontSize: 18, color: !_isTextMode ? Colors.blue.shade800 : Colors.blue.shade400)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() { _isTextMode = true; });
                    if (_rows.isNotEmpty) _rows[_focusedIndex].focusNode.requestFocus(); 
                  },
                  child: Text('ABC', style: TextStyle(fontSize: 18, color: _isTextMode ? Colors.blue.shade800 : Colors.blue.shade400)),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_hide, color: Colors.blue),
                  onPressed: () => FocusScope.of(context).unfocus(),
                ),
                const Spacer(),
                const Text('Total:  ', style: TextStyle(fontSize: 20, color: Colors.black87)),
                Text(
                  _grandTotal.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          if (!_isTextMode && !isNativeKeyboardOpen)
            CustomKeypad(onKeyPressed: _onKeyPressed),
        ],
      ),
    );
  }
}