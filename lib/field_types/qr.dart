import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/field_types/field_type_base.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class FieldTypeQR extends FieldType {
  final Function onListTap;
  final String Function()? regenerate;

  FieldTypeQR({required this.onListTap, this.regenerate});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    String code = _object.getFieldAdm(column.field, '');
    return code.isEmpty ? SizedBox.shrink() : IconButton(icon: Icon(FontAwesomeIcons.qrcode), onPressed: () => onListTap(_object, column));
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    TextEditingController qr = TextEditingController();
    var value = values[column.field] ?? '';

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
            qr.text = regenerate != null ? regenerate!() : uuid.v4();
            updateData(context, column, qr.text);
          })
    ]);
  }
}
