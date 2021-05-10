import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class FieldTypeQR extends FieldType {
  final Function onListTap;

  FieldTypeQR({@required this.onListTap});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    String code = _object.data()[column.field];
    return code.isEmpty
        ? SizedBox.shrink()
        : IconButton(
            icon: Icon(FontAwesome.qrcode),
            onPressed: () => onListTap(_object, column));
  }

  @override
  getEditContent(
      values, ColumnModule column, Function onValidate, Function onChange) {
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
                if (onChange != null) onChange(val);
              })),
      IconButton(
          icon: Icon(FontAwesome.refresh),
          onPressed: () {
            var uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});
            String nuevo = uuid.v4();
            print(nuevo);
            qr.text = nuevo;
            onChange(nuevo);
          })
    ]);
  }
}
