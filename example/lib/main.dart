import 'package:example/home.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      /*
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      */
      home: HomeScreen(),
    );
  }
}
