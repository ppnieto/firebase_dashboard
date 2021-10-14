import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, 50),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                border: Border.all(
                  color: Colors.white54,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Center(
                  child: Row(
                children: [
                  Text(
                      FirebaseAuth.instance.currentUser?.email ??
                          FirebaseAuth.instance.currentUser?.displayName ??
                          "-",
                      style: TextStyle(fontSize: 16)),
                  SizedBox(width: 5),
                  Icon(Icons.keyboard_arrow_down)
                ],
              )),
            )),
      ),
      onSelected: (value) async {
        if (value == 1) {
          await FirebaseAuth.instance.signOut();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
              value: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text('Salir'),
              ))
        ];
        /*
        return List.generate(5, (index) {
          return PopupMenuItem(
            child: Text('button no $index'),
          );
        });*/
      },
    );
  }
}
