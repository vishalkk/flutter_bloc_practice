import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Flutter demo",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const MyHomePage(),
  ));
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyHomePage"),
      ),
    );
  }
}
