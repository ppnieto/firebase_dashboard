import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class Listado3Screen extends StatelessWidget {
  const Listado3Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminScreen(
      module: DashboardModule(
        name: "listado3",
        title: "listado3",
        collection: "test",
        columns: [
          ColumnModule(
            label: "email",
            field: "email",
            type: FieldTypeText(),
          )
        ],
      ),
    );
  }
}
