import 'package:flutter/material.dart';

class MathTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    List<TextSpan> children = [];
    RegExp exp = RegExp(r'([\+\-\*\/\(\)])');
    
    text.splitMapJoin(
      exp,
      onMatch: (Match m) {
        children.add(TextSpan(
          text: m[0],
          style: style?.copyWith(color: Colors.orange.shade600, fontWeight: FontWeight.bold),
        ));
        return m[0]!;
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return span;
      },
    );

    return TextSpan(style: style, children: children);
  }
}