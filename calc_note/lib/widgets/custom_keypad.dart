import 'package:flutter/material.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onSwitchToText;

  const CustomKeypad({super.key, required this.onKeyPressed, required this.onSwitchToText});

  @override
  Widget build(BuildContext context) {
    final keys = [
      'C', '(', ')', '⌫',
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      '0', '.', '↵', '+'
    ];

    return Container(
      color: const Color(0xFFE8EEF2),
      padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 80), 
              Container(
                width: 40, height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.keyboard, color: Colors.black54),
                label: const Text('ABC', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                onPressed: onSwitchToText, 
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: keys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, 
              childAspectRatio: 1.4, 
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              String key = keys[index];
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _isOperator(key) ? Colors.orange.shade600 : Colors.black87,
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => onKeyPressed(key),
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: key == '↵' ? 28 : 24, // Hacemos la flecha un poco más grande
                    fontWeight: _isOperator(key) ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isOperator(String key) {
    return ['/', '*', '-', '+', 'C', '⌫', '↵', '(', ')'].contains(key);
  }
}