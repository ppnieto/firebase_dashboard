import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/dashboard.dart';

class FieldTypeRating extends FieldType {
  final bool showCount;
  final int startCount;
  final Color color;
  final double iconSize;

  FieldTypeRating(
      {this.startCount = 5,
      this.color = Colors.yellow,
      this.showCount = true,
      this.iconSize = 16});

  Widget buildCount(var rating) {
    if (this.showCount &&
        rating != null &&
        rating is Map &&
        rating.containsKey('count')) {
      return Text("(${rating['count']})");
    } else
      return SizedBox.shrink();
  }

  Widget buildStar(int index, var rating) {
    double avg = 0;

    if (rating != null && rating is Map && rating.containsKey('avg')) {
      avg = rating['avg'];
    }
    Icon icon;
    if (index >= avg) {
      icon = new Icon(
        Icons.star_border,
        color: color,
        size: iconSize,
      );
    } else if (index > avg - 1 && index < avg) {
      icon = new Icon(
        Icons.star_half,
        color: color,
        size: iconSize,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color,
        size: iconSize,
      );
    }
    return icon;
  }

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    var rating = _object.getFieldAdm(column.field, 0);
    return Row(
        children: List.generate(
                this.startCount, (index) => buildStar(index, rating)) +
            [buildCount(rating)]);
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object,
      Map<String, dynamic> values, ColumnModule column) {
    var rating = _object?.getFieldAdm(column.field, 0);
    return Row(
        children: List.generate(
                this.startCount, (index) => buildStar(index, rating)) +
            [buildCount(rating)]);
  }
}
