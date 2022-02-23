import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeSelect extends FieldType {
  final String? initialValue;
  final Map<String, String> options;
  final Widget? unselected;
  final Function? validate;
  final String? frozenValue;

  FieldTypeSelect(
      {required this.options,
      this.unselected,
      this.initialValue,
      this.validate,
      this.frozenValue});

  @override
  String getSyncStringContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      String key = _object.get(column.field);
      if (this.options.containsKey(key)) {
        return this.options[key] ?? "";
      } else {
        if (this.unselected != null) {
          return "<unselected>";
        }
      }
    }
    return "<sin asignar>";
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      String key = _object.get(column.field);
      if (this.options.containsKey(key)) {
        return Text(this.options[key] ?? "");
      } else {
        if (this.unselected != null) {
          return this.unselected;
        }
      }
    }

    return Text("<sin asignar>", style: TextStyle(color: Colors.red));
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values,
      ColumnModule column, Function onChange) {
    var value = values[column.field];

    return Container(
        width: 300,
        child: DropdownButtonFormField(
          value: value == null ? initialValue : value,
          isExpanded: true,
          items: options.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value),
              enabled: !(frozenValue != null && frozenValue == e.key),
            );
          }).toList(),
          onChanged: (frozenValue != null && value == frozenValue) ||
                  column.editable == false
              ? null
              : (val) {
                  onChange(val);
                },
          onSaved: (val) {
            onChange(val);
          },
          validator: (val) {
            if (column.mandatory && val == null) return "Campo obligatorio";
            if (validate != null) return validate!(initialValue, val);
            return null;
          },
        ));
  }

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[
          DropdownMenuItem(
            value: "",
            child: Text("Seleccione " + column.label.toLowerCase()),
          )
        ] +
        options.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Text(e.value),
            enabled: !(frozenValue != null && frozenValue == e.key),
          );
        }).toList();

    return Theme(
      data: Theme.of(context)
          .copyWith(inputDecorationTheme: InputDecorationTheme()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Container(
            width: 300,
            child: DropdownButtonFormField(
              value: value == null ? initialValue : value,
              isExpanded: true,
              items: items,
              onChanged: (frozenValue != null && value == frozenValue) ||
                      column.editable == false
                  ? null
                  : (val) {
                      onFilter(val);
                    },
              validator: (val) {
                if (column.mandatory && val == null) return "Campo obligatorio";
                if (validate != null) return validate!(initialValue, val);
                return null;
              },
            )),
      ),
    );
  }
}
