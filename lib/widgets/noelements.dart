import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NoElements extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextStyle? textStyle;
  final Widget? icon;
  const NoElements({super.key, required this.title, this.subtitle, this.textStyle, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon ?? const CircleAvatar(child: Icon(FontAwesomeIcons.info, size: 48), minRadius: 50).paddingAll(20),
        Text(title, style: textStyle).paddingOnly(bottom: 20),
        if (subtitle != null) Text(subtitle!, style: textStyle),
      ],
    );
  }
}
