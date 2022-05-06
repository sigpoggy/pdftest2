import 'package:flutter/material.dart';

class ModalDialog extends StatelessWidget {
  const ModalDialog({
    required this.content,
    this.insets = 10,
    this.cornerRadius = 20,
    Key? key}) : super(key: key);

  final Widget content;
  final double insets;
  final double cornerRadius;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius)),
      child: content,
      insetPadding: EdgeInsets.only(left: insets, right: insets),
    );
  }
}
