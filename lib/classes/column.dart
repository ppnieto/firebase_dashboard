import 'package:firebase_dashboard/dashboard.dart';

class ColumnModule {
  String label;
  String field;
  String? helpText;
  FieldType type;
  bool editable;
  bool showOnEdit;
  bool showOnNew;
  bool listable;
  bool excellable;
  bool clickToDetail;
  bool filter;
  bool mandatory;
  double? width;
  bool showLabelOnEdit;
  bool canSort;
  bool visible;

  ColumnModule({
    required this.label,
    required this.field,
    required this.type,
    this.editable = true,
    this.listable = true,
    this.clickToDetail = true,
    this.filter = true,
    this.mandatory = false,
    this.showOnEdit = true,
    this.showLabelOnEdit = true,
    this.width,
    this.visible = true,
    this.showOnNew = true,
    this.excellable = true,
    this.canSort = true,
    this.helpText,
  });
}
