import 'package:dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldTypeText extends FieldType {
  final RegExp? regexp;
  final bool nullable;
  final Function? showTextFunction;
  final bool obscureText;
  final bool emptyNull;
  final Widget? nullWidget;
  final int ellipsisLength;
  final bool tooltip;
  final int maxLines;

  final TextEditingController controller = TextEditingController();

  FieldTypeText(
      {this.nullable = true,
      this.regexp,
      this.showTextFunction,
      this.obscureText = false,
      this.emptyNull = false,
      this.tooltip = false,
      this.maxLines = 2,
      this.ellipsisLength = 0,
      this.nullWidget});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if ((_object.data() as Map).containsKey(column.field) && _object.get(column.field) != null) {
      String texto = showTextFunction == null ? _object[column.field].toString() : showTextFunction!(_object[column.field]);
      if (this.ellipsisLength > 0 && texto.length >= this.ellipsisLength) {
        return Text(texto);
      } else {
        if (tooltip) {
          return Tooltip(
              message: texto,
              child: Text(
                texto,
                maxLines: this.maxLines,
                overflow: TextOverflow.ellipsis,
              ));
        } else {
          return Text(texto);
        }
      }
    }
    return nullWidget == null ? Text("-") : nullWidget;
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column, Function? onValidate, Function? onChange) {
    var value = values[column.field];
    print("value == $value");
    controller.text = value ?? "";
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          if (onChange != null) onChange(controller.text);
        }
      },
      child: TextFormField(
          controller: controller,
          enabled: column.editable,
          obscureText: this.obscureText,
          enableSuggestions: this.obscureText,
          autocorrect: this.obscureText,
          decoration: InputDecoration(labelText: column.label, filled: !column.editable, fillColor: Colors.grey[100]),
          validator: (value) {
            if (regexp != null) {
              if (!regexp!.hasMatch(value ?? "")) {
                return "Formato incorrecto";
              }
            }
            return onValidate != null ? onValidate(value) : null;
          },
          onSaved: (val) {
            if (emptyNull) {
              val = (val ?? "").isEmpty ? null : val;
            }
            if (onChange != null) onChange(val);
          }),
    );
  }

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 250,
      child: TextField(
        decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Filtrar por " + column.label),
        onChanged: (val) {
          if (onFilter != null) onFilter(val);
        },
      ),
    );
  }
}
/*
class _Text extends StatefulWidget {
  final String text;
  final int ellipsisLength;
  const _Text({Key? key, required this.text, required this.ellipsisLength}) : super(key: key);

  @override
  __TextState createState() => __TextState();
}

class __TextState extends State<_Text> {
  late final String texto;
  bool collapsed = true;

  @override
  initState() {
    super.initState();
    this.texto = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(collapsed ? texto.substring(0, widget.ellipsisLength) + '...' : texto),
        IconButton(
            onPressed: () {
              setState(() {
                collapsed = !collapsed;
              });
            },
            icon: Icon(collapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left, color: Theme.of(context).highlightColor))
      ],
    );
  }
}
*/