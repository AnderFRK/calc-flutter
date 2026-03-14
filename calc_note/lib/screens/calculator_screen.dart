import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/calc_row.dart';
import '../widgets/custom_keypad.dart';
import '../widgets/calc_bottom_bar.dart';
import '../widgets/calc_drawer.dart'; 
import '../utils/file_service.dart'; // Asegúrate de tener este archivo creado

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

  String _currentFileName = "Nota Nueva";
  String _currentGuideNumber = ""; 
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _guideController = TextEditingController();

  List<Map<String, dynamic>> _savedFilesList = [];

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  // --- LÓGICA DE DATOS Y PERSISTENCIA ---
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    _currentFileName = prefs.getString('last_file_name') ?? "Nota Nueva";
    _currentGuideNumber = prefs.getString('last_guide_number') ?? "";
    
    _titleController.text = _currentFileName;
    _guideController.text = _currentGuideNumber;

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
    _refreshSavedFilesList(); 
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('last_file_name', _currentFileName);
    await prefs.setString('last_guide_number', _currentGuideNumber);
    
    List<String> dataToSave = _rows.map((row) => row.controller.text).toList();
    await prefs.setStringList('calc_data_$_currentFileName', dataToSave);

    List<String> indexList = prefs.getStringList('files_index') ?? [];
    
    Map<String, dynamic> fileInfo = {
      "title": _currentFileName,
      "guide": _currentGuideNumber,
      "total": _grandTotal,
      "date": DateTime.now().toIso8601String()
    };
    
    String jsonInfo = jsonEncode(fileInfo);
    
    indexList.removeWhere((item) => jsonDecode(item)['title'] == _currentFileName);
    indexList.add(jsonInfo);
    
    await prefs.setStringList('files_index', indexList);
    _refreshSavedFilesList();
  }

  Future<void> _refreshSavedFilesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> indexList = prefs.getStringList('files_index') ?? [];
    
    setState(() {
      _savedFilesList = indexList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
      _savedFilesList.sort((a, b) => b['date'].compareTo(a['date']));
    });
  }

  Future<void> _loadSpecificFile(String fileName, String guideNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_file_name', fileName);
    await prefs.setString('last_guide_number', guideNumber);
    _loadData(); 
    if (Navigator.canPop(context)) Navigator.pop(context); 
  }

  void _crearArchivoNuevo() {
    setState(() {
      _currentFileName = "Nota Nueva";
      _currentGuideNumber = "";
      _titleController.text = _currentFileName;
      _guideController.text = "";
      _rows.clear();
      _rows.add(CalcRow());
      _grandTotal = 0.0;
      _focusedIndex = 0;
    });
    _saveData();
    if (Navigator.canPop(context)) Navigator.pop(context); 
  }

  // --- LÓGICA DE EXPORTACIÓN E IMPORTACIÓN ---
  void _importarArchivo() async {
    var note = await FileService.importNote();
    if (note != null) {
      setState(() {
        _currentFileName = note['titulo'] ?? "Importado";
        _currentGuideNumber = note['guia'] ?? "";
        _rows.clear();
        for (String line in note['filas']) {
          CalcRow row = CalcRow();
          row.controller.text = line;
          _rows.add(row);
        }
      });
      for (int i = 0; i < _rows.length; i++) {
        _calculateRow(i, _rows[i].controller.text);
      }
      _saveData(); 
      if (Navigator.canPop(context)) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cálculo importado exitosamente')));
    }
  }

  void _exportarActual() {
    List<String> data = _rows.map((r) => r.controller.text).toList();
    FileService.exportNote(_currentFileName, _currentGuideNumber, data);
  }

  // --- DIÁLOGO DE EDICIÓN ---
  void _mostrarDialogoEdicion() {
    _titleController.text = _currentFileName;
    _guideController.text = _currentGuideNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Detalles del Documento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Nombre del Archivo"),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _guideController,
                decoration: const InputDecoration(labelText: "N° de Guía / Boleta (Opcional)"),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentFileName = _titleController.text.isNotEmpty ? _titleController.text : "Nota Nueva";
                  _currentGuideNumber = _guideController.text;
                });
                _saveData();
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            )
          ],
        );
      }
    );
  }

  // --- LÓGICA DE MATEMÁTICAS ---
  void _onKeyPressed(String key) {
    if (_rows.isEmpty) return;
    final controller = _rows[_focusedIndex].controller;
    int cursorPos = controller.selection.baseOffset;
    if (cursorPos < 0) cursorPos = controller.text.length;

    setState(() {
      if (key == 'C') {
        controller.text = '';
      } else if (key == '⌫') {
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

  // --- UI PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    bool isNativeKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      drawer: CalcDrawer(
        savedFilesList: _savedFilesList,
        onNewFile: _crearArchivoNuevo,
        onFileLoaded: _loadSpecificFile,
        onImport: _importarArchivo, 
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), 
        title: GestureDetector(
          onTap: _mostrarDialogoEdicion,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_currentFileName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  const Icon(Icons.edit, color: Colors.white70, size: 16),
                ],
              ),
              if (_currentGuideNumber.isNotEmpty)
                Text("Guía: $_currentGuideNumber", style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF3399FF),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: _exportarActual),
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
          
          CalcBottomBar(
            isTextMode: _isTextMode,
            grandTotal: _grandTotal,
            onModeChanged: (isText) {
              setState(() { _isTextMode = isText; });
              if (isText) {
                if (_rows.isNotEmpty) _rows[_focusedIndex].focusNode.requestFocus();
              } else {
                FocusScope.of(context).unfocus();
                if (_rows.isNotEmpty) _rows[_focusedIndex].focusNode.requestFocus();
              }
            },
            onHideKeyboard: () => FocusScope.of(context).unfocus(),
          ),
          
          if (!_isTextMode && !isNativeKeyboardOpen)
            CustomKeypad(onKeyPressed: _onKeyPressed),
        ],
      ),
    );
  }
}