import 'package:example/listado2.dart';
import 'package:flutter/material.dart';

class Listado1Screen extends StatelessWidget {
  const Listado1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Listado 1")),
      body: Center(
          child: ElevatedButton(
        child: Text("goto 2"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Listado2Screen()),
          );
        },
      )),
    );
  }
}
