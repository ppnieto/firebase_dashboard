import 'package:dashboard/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginMethod { loginPassword, google, facebook, apple, twitter }

class LoginScreen extends StatelessWidget {
  final String title;
  final String logoURL;
  final String imageURL;
  final bool allowReminder;
  final bool useGoogle;
  final bool remindCredentials;

  // para depuracion, meter los datos directamente desde fuera
  final String userName;
  final String password;

  final Function(LoginMethod, String, String) onEntrar;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen(
      {Key key,
      @required this.title,
      @required this.onEntrar,
      this.allowReminder = false,
      this.logoURL,
      this.imageURL,
      this.remindCredentials = false,
      this.useGoogle = true,
      this.userName = "",
      this.password = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    emailController.text = this.userName;
    passwordController.text = this.password;

    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 220, 220, 1),
      bottomNavigationBar: Container(
          height: 30,
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                child: FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox.shrink();
                    return Text(snapshot.data.version,
                        style: TextStyle(color: Colors.grey));
                  },
                )),
          )),
      body: Responsive(
        mobile: _LoginMobile(parent: this),
        desktop: _LoginDesktop(parent: this),
      ),
    );
  }
}

class _LoginMobile extends StatefulWidget {
  final LoginScreen parent;

  const _LoginMobile({Key key, @required this.parent}) : super(key: key);

  @override
  __LoginMobileState createState() => __LoginMobileState();
}

class __LoginMobileState extends State<_LoginMobile> {
  bool recordarCredenciales = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      bool recordar = prefs.getBool('recordarCredenciales') ?? false;
      if (recordar) {
        String userName = prefs.getString("userName");
        String password = prefs.getString("password");
        widget.parent.emailController.text = userName;
        widget.parent.passwordController.text = password;
        setState(() {
          recordarCredenciales = true;
        });
      }
    });
  }

  setPreferences() {
    if (recordarCredenciales) {
      String userName = widget.parent.emailController.text;
      String password = widget.parent.passwordController.text;
      SharedPreferences.getInstance().then((SharedPreferences prefs) {
        prefs.setBool('recordarCredenciales', true);
        prefs.setString('userName', userName);
        prefs.setString('password', password);
      });
    }
  }

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
                      Text(widget.parent.title,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      SizedBox(height: 50),
                      Text('Usuario'),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        decoration:
                            InputDecoration(suffixIcon: Icon(Icons.person)),
                        //decoration: InputDecoration(labelText: "email"),
                        controller: widget.parent.emailController,
                      ),
                      SizedBox(height: 20),
                      Text('Contraseña'),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                          obscureText: true,
                          decoration:
                              InputDecoration(suffixIcon: Icon(Icons.lock)),
                          //decoration: InputDecoration(labelText: "contraseña"),
                          controller: widget.parent.passwordController),
                      SizedBox(height: 10),
                      widget.parent.remindCredentials
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  SizedBox(),
                                  Expanded(
                                    child: CheckboxListTile(
                                        title: Text("Recordar credenciales"),
                                        value: recordarCredenciales,
                                        onChanged: (val) {
                                          setState(() {
                                            recordarCredenciales = val;
                                          });
                                        }),
                                  )
                                ])
                          : SizedBox.shrink(),
                      widget.parent.allowReminder
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Container(),
                                  TextButton(
                                    child: Text("Olvidé mi contraseña"),
                                    onPressed: () {},
                                  )
                                ])
                          : SizedBox.shrink(),
                      SizedBox(height: 40),
                      TextButtonTheme(
                          data: TextButtonThemeData(
                              style: TextButton.styleFrom(
                            minimumSize: Size(300, 50),
                            padding: EdgeInsets.only(
                                top: 15, bottom: 15, left: 30, right: 30),
                            primary: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                          )),
                          child: TextButton(
                              child: Text("Entrar",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () async {
                                this.setPreferences();
                                widget.parent.onEntrar(
                                    LoginMethod.loginPassword,
                                    widget.parent.emailController.text,
                                    widget.parent.passwordController.text);
                              })),
                      Expanded(child: Container()),
                      widget.parent.useGoogle
                          ? TextButton.icon(
                              onPressed: () {
                                widget.parent
                                    .onEntrar(LoginMethod.google, "", "");
                              },
                              icon: Icon(FontAwesome.google),
                              label: Text("Entrar usando Google"))
                          : SizedBox.shrink(),
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
