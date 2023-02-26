import 'package:firebase_dashboard/controllers/login.dart';
import 'package:firebase_dashboard/responsive.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum LoginMethod { loginPassword, google, facebook, apple, twitter }

class LoginScreen extends StatelessWidget {
  final String title;
  final String? logoURL;
  final String? logoAsset;
  final Widget? logoWidget;
  final String? imageURL;
  final String? imageAsset;
  final bool allowReminder;
  final bool useGoogle;
  final bool remindCredentials;

  // para depuracion, meter los datos directamente desde fuera
  final String userName;
  final String password;

  final Function(LoginMethod, String, String) onEntrar;
  final Function(String)? onForgotPassword;

  LoginScreen(
      {Key? key,
      required this.title,
      required this.onEntrar,
      this.onForgotPassword,
      this.allowReminder = false,
      this.logoURL,
      this.logoAsset,
      this.logoWidget,
      this.imageURL,
      this.imageAsset,
      this.remindCredentials = false,
      this.useGoogle = true,
      this.userName = "",
      this.password = ""})
      : super(key: key);

  Widget getLogo() {
    if (logoURL != null) {
      return Image.network(logoURL!);
    } else if (logoAsset != null) {
      return Image.asset(logoAsset!);
    } else if (logoWidget != null) {
      return logoWidget!;
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      /*
      bottomNavigationBar: Container(
          height: 30,
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                child: FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
                    if (!snapshot.hasData) return SizedBox.shrink();
                    return Text(snapshot.data!.version, style: TextStyle(color: Colors.grey));
                  },
                )),
          )),
          */
      body: Responsive(
        mobile: _LoginMobile(parent: this),
        desktop: _LoginDesktop(parent: this),
      ),
    );
  }
}

class _LoginMobile extends StatelessWidget {
  final LoginScreen parent;

  _LoginMobile({Key? key, required this.parent}) : super(key: key);

  Future<void> doEnter(LoginController controller) async {
    controller.loading = true;
    controller.setPreferences();
    await parent.onEntrar(LoginMethod.loginPassword, controller.emailController.text, controller.passwordController.text);
    controller.loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
        init: LoginController(),
        builder: (controller) {
          return Center(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50.0),
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ListView(shrinkWrap: true,
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!Responsive.isDesktop(context)) parent.getLogo(),
                        SizedBox(height: 20),
                        Text(parent.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        SizedBox(height: 50),
                        Text('Usuario'),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(suffixIcon: Icon(Icons.person)),
                          textInputAction: TextInputAction.next,
                          //decoration: InputDecoration(labelText: "email"),
                          controller: controller.emailController,
                        ),
                        SizedBox(height: 20),
                        Text('Contraseña'),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(suffixIcon: Icon(Icons.lock)),
                            onFieldSubmitted: (value) async {
                              await doEnter(controller);
                            },
                            textInputAction: TextInputAction.send,
                            controller: controller.passwordController),
                        SizedBox(height: 10),
                        parent.remindCredentials
                            ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                SizedBox(),
                                Expanded(
                                  child: CheckboxListTile(
                                      title: Text("Recordar credenciales"),
                                      value: controller.recordarCredenciales,
                                      onChanged: (val) {
                                        controller.recordarCredenciales = val ?? false;
                                      }),
                                )
                              ])
                            : SizedBox.shrink(),
                        SizedBox(height: 10),
                        parent.allowReminder
                            ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Container(),
                                TextButton(
                                  child: Text("Olvidé mi contraseña", style: TextStyle(color: Theme.of(context).primaryColor)),
                                  onPressed: () {
                                    TextEditingController emailController = TextEditingController();
                                    Get.defaultDialog(
                                      titlePadding: EdgeInsets.all(30),
                                      contentPadding: EdgeInsets.all(20),
                                      title: "Introduzca su dirección de email",
                                      content: Container(
                                        height: 90,
                                        child: Column(
                                          children: [TextField(controller: emailController)],
                                        ),
                                      ),
                                      actions: [
                                        TextButtonTheme(
                                            data: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                              padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
                                              primary: Colors.white,
                                              backgroundColor: Theme.of(context).primaryColor,
                                            )),
                                            child: TextButton(
                                                onPressed: () {
                                                  if (emailController.text.isNotEmpty) {
                                                    if (parent.onForgotPassword != null) {
                                                      parent.onForgotPassword!(emailController.text);
                                                    }
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Si el usuario existe en el sistema se le enviarán las instrucciones por correo electrónico"),
                                                    ));
                                                  }
                                                },
                                                child: Text("Obtener nueva contraseña", style: TextStyle(color: Colors.white, fontSize: 18))))
                                      ],
                                    );
                                  },
                                )
                              ])
                            : SizedBox.shrink(),
                        SizedBox(height: 40),
                        TextButtonTheme(
                            data: TextButtonThemeData(
                                style: TextButton.styleFrom(
                              minimumSize: Size(300, 50),
                              padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
                              foregroundColor: Theme.of(context).canvasColor,
                              backgroundColor: Theme.of(context).primaryColor,
                            )),
                            child: controller.loading
                                ? const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator()))
                                : Container(
                                    height: 60,
                                    child: TextButton(
                                        child: Text("Entrar", style: TextStyle(fontSize: 22)),
                                        onPressed: () async {
                                          await doEnter(controller);
                                        }),
                                  )),
                        SizedBox(height: 40),
                        parent.useGoogle
                            ? TextButton.icon(
                                onPressed: () {
                                  parent.onEntrar(LoginMethod.google, "", "");
                                },
                                icon: Icon(FontAwesomeIcons.google, color: Theme.of(context).accentColor),
                                label: Text("Entrar usando Google", style: TextStyle(color: Theme.of(context).accentColor)))
                            : SizedBox.shrink(),
                      ])));
        });
  }
}

class _LoginDesktop extends StatelessWidget {
  final LoginScreen parent;

  const _LoginDesktop({
    Key? key,
    required this.parent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
              color: Theme.of(context).primaryColor,
              child: Column(children: [Spacer(), parent.getLogo().paddingSymmetric(horizontal: 40, vertical: 10), Spacer()])),
        ),
        Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).canvasColor,
              child: _LoginMobile(parent: parent),
            ))
      ],
    );
    /*
    if (1 == 2)
      return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 25.0),
              constraints: BoxConstraints(
                maxWidth: 1000,
              ),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
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
                                  image: NetworkImage(parent.imageURL!),
                                  fit: BoxFit.cover,
                                )
                              : parent.imageAsset != null
                                  ? DecorationImage(image: AssetImage(parent.imageAsset!), fit: BoxFit.cover)
                                  : null,
                        ),
                      ),
                      Container(
                        width: 400,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.2), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                        ),
                      ),
                      if (parent.logoURL != null)
                        Positioned(
                          child: Image.network(parent.logoURL!),
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                        ),
                      if (parent.logoAsset != null)
                        Positioned(
                          child: Image.asset(parent.logoAsset!),
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                        ),
                      if (parent.logoWidget != null)
                        Positioned(
                          child: parent.logoWidget!,
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                        )
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
      */
  }
}
