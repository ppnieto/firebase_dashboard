import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class FieldTypeColor extends FieldType {
  FieldTypeColor();

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    String color = _object.getFieldAdm(column.field, Colors.grey.hex);
    return Container(width: 30, height: 30, color: color.toColor);
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    String strColor = _object?.getFieldAdm(column.field, values[column.field] ?? "aaaaaa") ?? "aaaaaa";
    return Row(
      children: [
        StatefulBuilder(builder: (context, setStateBuilder) {
          return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context2) {
                    return AlertDialog(
                      title: const Text('Pick a color!'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: strColor.toColor,
                          onColorChanged: (newColor) {
                            updateData(context, column, newColor.hex);
                          },
                        ),
                        // Use Material color picker:
                        //
                        // child: MaterialPicker(
                        //   pickerColor: pickerColor,
                        //   onColorChanged: changeColor,
                        //   showLabel: true, // only on portrait mode
                        // ),
                        //
                        // Use Block color picker:
                        //
                        // child: BlockPicker(
                        //   pickerColor: currentColor,
                        //   onColorChanged: changeColor,
                        // ),
                        //
                        // child: MultipleChoiceBlockPicker(
                        //   pickerColors: currentColors,
                        //   onColorsChanged: changeColors,
                        // ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('Aceptar'),
                          onPressed: () {
                            setStateBuilder(() {});
                            Navigator.of(context2).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(width: 30, height: 30, color: strColor.toColor));
        }),
        Spacer(),
      ],
    );
  }
}

/*
extension HexColorExt on String {
  Color get fromHex {    
    final buffer = StringBuffer();
    if (this.length == 6 || this.length == 7) {
      buffer.write('ff');
    }

    if (this.startsWith('#')) {
      buffer.write(this.replaceFirst('#', ''));
    } else {
      buffer.write(this);
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension HexColorExt2 on Color {
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
*/