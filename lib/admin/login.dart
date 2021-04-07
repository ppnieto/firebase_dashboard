import 'package:dashboard/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum LoginMethod { loginPassword, google, facebook, apple, twitter }

class LoginScreen extends StatelessWidget {
  final String title;
  final String logoURL;
  final String imageURL;

  final Function(LoginMethod, String, String) onEntrar;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({
    Key key,
    @required this.title,
    @required this.onEntrar,
    this.logoURL,
    this.imageURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 220, 220, 1),
      body: Responsive(
        mobile: _LoginMobile(parent: this),
        desktop: _LoginDesktop(parent: this),
      ),
    );
  }
}

class _LoginMobile extends StatelessWidget {
  final LoginScreen parent;

  const _LoginMobile({Key key, @required this.parent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Center(
            child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 50.0),
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Text(parent.title,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      SizedBox(height: 50),
                      Text('Usuario'),
                      TextField(
                        decoration:
                            InputDecoration(suffixIcon: Icon(Icons.person)),
                        //decoration: InputDecoration(labelText: "email"),
                        controller: parent.emailController,
                      ),
                      SizedBox(height: 20),
                      Text('Contraseña'),
                      TextField(
                          obscureText: true,
                          decoration:
                              InputDecoration(suffixIcon: Icon(Icons.lock)),
                          //decoration: InputDecoration(labelText: "contraseña"),
                          controller: parent.passwordController),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            TextButton(
                              child: Text("Olvidé mi contraseña"),
                              onPressed: () {},
                            )
                          ]),
                      SizedBox(height: 40),
                      TextButtonTheme(
                          data: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  minimumSize: Size(300, 50),
                                  padding: EdgeInsets.only(
                                      top: 15, bottom: 15, left: 30, right: 30),
                                  primary: Colors.white,
                                  backgroundColor: Colors.blue)),
                          child: TextButton(
                              child: Text("Entrar",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () async {
                                if (parent.emailController.text.isEmpty ||
                                    parent.passwordController.text.isEmpty) {
                                  print("error");
                                } else {
                                  parent.onEntrar(
                                      LoginMethod.loginPassword,
                                      parent.emailController.text,
                                      parent.passwordController.text);
                                  /*
                                  auth.User user =
                                      await _auth.signInWithEmailAndPassword(
                                          parent.emailController.text,
                                          parent.passwordController.text);
                                  if (user != null) {
                                    onUserLogged();
                                  } else {
                                    parent.showError(context,
                                        'Error en la identificación del usuario');
                                  }
                                  */
                                }
                              })),
                      Expanded(child: Container()),
                      TextButton.icon(
                          onPressed: () {
                            parent.onEntrar(LoginMethod.google, "", "");
                          },
                          icon: Icon(FontAwesome.google),
                          label: Text("Entrar usando Google")),
                    ]))));
  }
}

class _LoginDesktop extends StatelessWidget {
  final LoginScreen parent;

  const _LoginDesktop({
    Key key,
    @required this.parent,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 25.0),
            constraints: BoxConstraints(
              maxWidth: 1000,
            ),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 400,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: parent.imageURL != null
                            ? DecorationImage(
                                image: NetworkImage(parent.imageURL),
                                fit: BoxFit.cover)
                            : null,
                      ),
                    ),
                    Container(
                      width: 400,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter),
                      ),
                    ),
                    parent.logoURL != null
                        ? Positioned(
                            child: Image.network(parent.logoURL),
                            left: 10.0,
                            right: 10.0,
                            top: 10.0,
                          )
                        : SizedBox.shrink()
                  ],
                ),
                Expanded(
                    child: _LoginMobile(
                  parent: parent,
                )),
              ],
            )),
      ),
    );
  }
}
