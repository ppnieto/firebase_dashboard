import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/screens/detalle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';

class FieldTypeNumber extends FieldType {
  final double maxValue;
  final double minValue;
  final String Function(double val)? formatter;

  final double? defaultValue;
  final int decimals;
  final TextEditingController _controller = TextEditingController();

  FieldTypeNumber({this.defaultValue, this.decimals = 0, this.maxValue = 100000, this.minValue = 0, this.formatter});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    var num = getField(_object, column.field, 0);
    if (num is String) {
      num = double.parse(num as String);
    }
    if (num is int) {
      num = num.toDouble();
    }
    if (decimals > 0) {
      return Text(num.toStringAsFixed(decimals));
    } else if (formatter != null) {
      return Text(formatter!(num));
    } else {
      return super.getListContent(context, _object, column);
    }
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = getFieldFromMap(values, column.field, 0.0);
    if (_object == null) value = defaultValue;

    if (_object?.hasFieldAdm(column.field) == false && value != null) {
      updateData(context, column, value);
    }
    if (value != null) {
      _controller.text = value.toString();
    }

    return TextFormField(
        controller: _controller,
        enabled: column.editable,
        keyboardType: TextInputType.numberWithOptions(decimal: decimals > 0),
        decoration: InputDecoration(
            labelText: column.label,
            filled: !column.editable,
            fillColor: column.editable ? Theme.of(context).canvasColor.withAlpha(1) : Theme.of(context).disabledColor),
        validator: (value) {
          //print("validator ${column.field} = $value");
          if (column.editable == false) return null;
          if ((value == null || value.isEmpty) && column.mandatory) return "El campo es obligatorio";

          if (double.tryParse(value.toString()) == null) {
            print("no es un número válido");
            return "No es un número válido";
          }
          if (column.mandatory && (value == null || value.isEmpty)) {
            print("campo obligatorio");
            return "Campo obligatorio";
          }
          double v = double.parse(value.toString());
          if (v > maxValue) {
            return "El valor $v es mayor que el máximo permitido ($maxValue)";
          }
          if (v < minValue) {
            return "El valor $v es menor que el mínimo permitido ($minValue)";
          }
          return null;
        },
        onSaved: (val) {
          //print("onSaved $val");
          if (!column.editable) return;
          val = (val ?? "").isEmpty ? null : val;
          double d = double.parse(val.toString());
          //print("guardamos número $d");
          updateData(context, column, d);
        });
  }
}
