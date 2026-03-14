import 'package:flutter/material.dart';

class CalcBottomBar extends StatelessWidget {
  final bool isTextMode;
  final double grandTotal;
  final Function(bool) onModeChanged;
  final VoidCallback onHideKeyboard;

  const CalcBottomBar({
    super.key,
    required this.isTextMode,
    required this.grandTotal,
    required this.onModeChanged,
    required this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: const Color(0xFFB3D9FF), 
      child: Row(
        children: [
          TextButton(
            onPressed: () => onModeChanged(false),
            child: Text('123', style: TextStyle(fontSize: 18, color: !isTextMode ? Colors.blue.shade800 : Colors.blue.shade400)),
          ),
          TextButton(
            onPressed: () => onModeChanged(true),
            child: Text('ABC', style: TextStyle(fontSize: 18, color: isTextMode ? Colors.blue.shade800 : Colors.blue.shade400)),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_hide, color: Colors.blue),
            onPressed: onHideKeyboard,
          ),
          const Spacer(),
          const Text('Total:  ', style: TextStyle(fontSize: 20, color: Colors.black87)),
          Text(
            grandTotal.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}