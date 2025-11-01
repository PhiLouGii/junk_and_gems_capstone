import 'package:flutter/material.dart';
import 'package:junk_and_gems/components/language_toggle_button.dart';

class FloatingLanguageButton extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const FloatingLanguageButton({
    super.key,
    this.top = 16,
    this.right = 16,
    this.bottom,
    this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: LanguageToggleButton(),
    );
  }
}