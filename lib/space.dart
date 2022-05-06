import 'package:flutter/material.dart';

class VSpace extends StatelessWidget {
  const VSpace(this.size, {Key? key}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
    );
  }
}

class HSpace extends StatelessWidget {
  const HSpace(this.size, {Key? key}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
    );
  }
}

class NoSpace extends StatelessWidget {
  const NoSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
