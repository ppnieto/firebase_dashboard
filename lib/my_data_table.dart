import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MyDataTable extends StatefulWidget {
  final Module module;

  MyDataTable({Key key, @required this.module}) : super(key: key);

  @override
  _MyDataTableState createState() => _MyDataTableState();
}

class _MyDataTableState extends State<MyDataTable> {
  ScrollController _scrollController;
  bool isLoading = false;
  int pageCount = 1;
  List<DocumentSnapshot> dataList = [];

  @override
  void initState() {
    super.initState();
    _loadNextPage();

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("comes to bottom $isLoading");
        isLoading = true;
        _loadNextPage();
/*
        if (isLoading) {
          print("RUNNING LOAD MORE");

          pageCount = pageCount + 1;

          addItemIntoLisT(pageCount);
        }
        */
      });
    }
  }

  Future<void> _loadNextPage() async {
    Query query =
        FirebaseFirestore.instance.collection(widget.module.collection);
    if (widget.module.orderBy != null) {
      query = query.orderBy(widget.module.orderBy);
    }

    if (widget.module.reverseOrderBy != null) {
      query = query.orderBy(widget.module.reverseOrderBy, descending: true);
    }

    query.limit(widget.module.rowsPerPage);

    if (dataList.isNotEmpty) {
      query.startAfterDocument(dataList.last);
    }
    QuerySnapshot qs = await query.get();
    List<DocumentSnapshot> nuevos = qs.docs;
    dataList.addAll(nuevos);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(controller: _scrollController, children: [
      PaginatedDataTable(
          rowsPerPage: dataList.length, //widget.module.rowsPerPage,
          columns: widget.module.columns
                  .where((element) => element.listable)
                  .map((column) {
                return DataColumn(label: Text(column.label));
              }).toList() +
              (widget.module.canRemove ? [DataColumn(label: Container())] : []),
          source: MyDataTableSource(dataList, widget.module, context, (index) {
            /*
                setState(() {
                  detalle = docs[index];
                  updateData = detalle.data();
                  tipo = TipoPantalla.detalle;
                });
                */
          })),
      isLoading ? CircularProgressIndicator() : SizedBox.shrink()
    ]);
  }
}

class MyDataTableSource extends DataTableSource {
  List<DocumentSnapshot> docs;
  BuildContext context;
  Module module;
  Function onTap;
  int indexSelected = 3;
  MyDataTableSource(this.docs, this.module, this.context, this.onTap);
  @override
  DataRow getRow(int index) {
    QueryDocumentSnapshot _object = docs[index];
    return DataRow.byIndex(
        index: index,
        cells: module.columns
                .where((element) => element.listable)
                .map<DataCell>((column) {
              // set context
              column.type.setContext(context);
              return DataCell(column.getListContent(_object),
                  onTap: column.clickToDetail && module.canEdit
                      ? () {
                          this.onTap(index);
                        }
                      : null);
            }).toList() +
            (module.canRemove
                ? [
                    DataCell(RaisedButton.icon(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(FontAwesome.remove, color: Colors.white),
                      label:
                          Text("Borrar", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        /*
                        doBorrar(context, _object.reference, () {
                          if (module.onRemove != null) {
                            module.onRemove(_object);
                          }
                        });
                        */
                      },
                    ))
                  ]
                : []));
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => docs.length;

  @override
  int get selectedRowCount => 0;
}
