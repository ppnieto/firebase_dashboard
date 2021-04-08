import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';

class FieldTypeLocation extends FieldType {
  @override
  getEditContent(
      value, ColumnModule column, Function onValidate, Function onChange) {
    TextEditingController latitude = TextEditingController();
    TextEditingController longitude = TextEditingController();

    latitude.text = value?.latitude != null ? value.latitude.toString() : "0";
    longitude.text =
        value?.longitude != null ? value.longitude.toString() : "0";

    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: latitude,
                decoration: InputDecoration(
                  labelText: column.label + " latitud",
                ),
                validator: (value) {
                  return onValidate != null ? onValidate(value) : null;
                },
                onSaved: (val) {
                  GeoPoint geoPoint = GeoPoint(double.parse(latitude.text),
                      double.parse(longitude.text));
                  if (onChange != null) onChange(geoPoint);
                })),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: TextFormField(
              controller: longitude,
              decoration: InputDecoration(
                labelText: column.label + " longitud",
              ),
              validator: (value) {
                return onValidate != null ? onValidate(value) : null;
              }),
        )
      ],
    );
  }
}
