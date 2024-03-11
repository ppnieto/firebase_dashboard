import 'package:flutter/material.dart';

class DashLoading extends StatelessWidget {
  final double? size;
  final Color? color;
  const DashLoading({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 96,
        height: size ?? 96,
        child: CircularProgressIndicator(
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
