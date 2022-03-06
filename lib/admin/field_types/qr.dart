import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class FieldTypeQR extends FieldType {
  final Function onListTap;

  FieldTypeQR({required this.onListTap});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    String code = _object.get(column.field);
    return code.isEmpty ? SizedBox.shrink() : IconButton(icon: Icon(FontAwesomeIcons.qrcode), onPressed: () => onListTap(_object, column));
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    TextEditingController qr = TextEditingController();
    var value = values[column.field];

    qr.text = value;
    /*
    if (qr.text.isEmpty) {
      var uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});
      qr.text = uuid.v4();
    }
    */

    return Row(children: [
      Expanded(
          child: TextFormField(
              controller: qr,
              decoration: InputDecoration(
                labelText: column.label,
              ),
              onSaved: (val) {
                updateData(context, column, val);
              })),
      IconButton(
          icon: Icon(FontAwesomeIcons.sync),
          onPressed: () {
            var uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});
            String nuevo = uuid.v4();
            print(nuevo);
            qr.text = nuevo;
            updateData(context, column, nuevo);
          })
    ]);
  }
}
