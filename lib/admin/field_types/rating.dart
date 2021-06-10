import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';

class FieldTypeRating extends FieldType {
  final int startCount;
  final Color color;

  FieldTypeRating({this.startCount = 5, this.color = Colors.yellow});

  Widget buildStar(int index, var rating) {
    if (rating == null) return SizedBox.shrink();
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Theme.of(context).buttonColor,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
      );
    }
    return icon;
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    var rating = _object.get(column.field);

    return Row(
        children: List.generate(
            this.startCount, (index) => buildStar(index, rating)));
  }
}
