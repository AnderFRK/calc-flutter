import 'package:flutter/material.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CustomKeypad({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    // Teclado más parecido al original
    final keys = [
      '7', '8', '9', '⌫', 'C',
      '4', '5', '6', '(', ')',
      '1', '2', '3', '*', '/',
      '0', '00', '.', '+', '-',
      '↵', '=', '', '', ''
    ];

    return Container(
      color: const Color(0xFFB3D9FF), 
      child: GridView.builder(
        shrinkWrap: true, 
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(), 
        itemCount: 20, // Solo mostramos 20 botones útiles
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 columnas como en tu imagen
          childAspectRatio: 1.1, 
          crossAxisSpacing: 1, // Líneas separadoras finas
          mainAxisSpacing: 1,
        ),
        itemBuilder: (context, index) {
          String key = keys[index];
          bool isNumber = RegExp(r'^[0-9\.]+$').hasMatch(key);
          
          return Material(
            color: isNumber ? const Color(0xFFE6F2FF) : Colors.transparent, // Números claros, operadores toman el fondo
            child: InkWell(
              onTap: () => onKeyPressed(key),
              child: Center(
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: key == '↵' ? 26 : 22, 
                    fontWeight: isNumber ? FontWeight.w500 : FontWeight.bold,
                    color: Colors.black87
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}