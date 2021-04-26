import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FieldTypeLocation extends FieldType {
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  @override
  getEditContent(
      value, ColumnModule column, Function onValidate, Function onChange) {
    GeoPoint position;
    if (value == null) {
      value = GeoPoint(0, 0);
    }
    if (value is GeoPoint) {
      position = value;
    } else {
      return Text("error");
    }

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
        ),
        SizedBox(
          width: 20,
        ),
        IconButton(
          icon: Icon(Icons.map),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _LocationDialog(parent: this);
                });
          },
        )
      ],
    );
  }
}

class _LocationDialog extends StatelessWidget {
  final FieldTypeLocation parent;

  LatLng newPosition;
  Completer<GoogleMapController> _controller = Completer();

  _LocationDialog({Key key, this.parent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    newPosition = LatLng(double.parse(parent.latitude.text),
        double.parse(parent.longitude.text));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      width: 800,
      height: 700,
      padding: EdgeInsets.all(50),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Ubicar posición",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Arrastre el marcador rojo para ubicar la posición exacta",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
                child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                  bearing: 192.8334901395799,
                  target: newPosition,
                  tilt: 59.440717697143555,
                  zoom: 15),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: Set<Marker>.of([
                Marker(
                    markerId: MarkerId("1"),
                    draggable: true,
                    position: newPosition,
                    onDragEnd: ((newPosition) {
                      this.newPosition = newPosition;
                    }))
              ]),
            )),
          ),
          SizedBox(
            height: 22,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      parent.latitude.text = newPosition.latitude.toString();
                      parent.longitude.text = newPosition.longitude.toString();

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Aceptar",
                      style: TextStyle(fontSize: 18),
                    )),
                SizedBox(width: 20),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancelar",
                      style: TextStyle(fontSize: 18),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
