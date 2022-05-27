import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter/material.dart';

class FieldTypeSelect extends FieldType {
  final String? initialValue;
  final Map<String, String> options;
  final Widget? unselected;
  final Function? validate;
  final String? frozenValue;
  final bool editInList;

  FieldTypeSelect({required this.options, this.unselected, this.initialValue, this.validate, this.frozenValue, this.editInList = false});

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
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (editInList) {
      String content = getSyncStringContent(_object, column);

      return Container(
          width: 300,
          child: PopupMenuButton<String>(
              tooltip: content,
              child: Text(
                content,
                //style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              itemBuilder: (context) {
                return <PopupMenuItem<String>>[PopupMenuItem<String>(value: "", child: Text("<sin asignar>", style: TextStyle(color: Colors.red)))] +
                    options.entries.map((e) {
                      return PopupMenuItem<String>(value: e.key, child: Text(e.value));
                    }).toList();
              },
              onSelected: (String ref) {
                _object.reference.update({column.field: ref}).then((value) => print("updated!!!"));
              })

          /*
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
            onChanged: (frozenValue != null && value == frozenValue) || column.editable == false
                ? null
                : (val) {
                    updateData(context, column, val);
                  },
            onSaved: (val) {
              updateData(context, column, val);
            },
            validator: (val) {
              if (column.mandatory && val == null) return "Campo obligatorio";
              if (validate != null) return validate!(initialValue, val);
              return null;
            },
          )*/
          );
    } else {
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
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
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
          onChanged: (frozenValue != null && value == frozenValue) || column.editable == false
              ? null
              : (val) {
                  updateData(context, column, val);
                },
          onSaved: (val) {
            updateData(context, column, val);
          },
          validator: (val) {
            print("valudate select");
            if (column.mandatory && val == null) return "Campo obligatorio";
            if (validate != null) return validate!(initialValue, val);
            return null;
          },
        ));
  }

  @override
  getFilterContent(BuildContext context, value, ColumnModule column, Function onFilter) {
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
      data: Theme.of(context).copyWith(inputDecorationTheme: InputDecorationTheme()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Container(
            width: 300,
            child: DropdownButtonFormField(
              value: value == null ? initialValue : value,
              isExpanded: true,
              items: items,
              onChanged: (frozenValue != null && value == frozenValue) || column.editable == false
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
