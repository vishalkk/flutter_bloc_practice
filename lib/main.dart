import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'dart:math' as math show Random;

void main() {
  runApp(MaterialApp(
    title: "Flutter demo",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const MyHomePage(),
  ));
}

const names = ['Vishal', 'Krishna', 'Kajale'];

//get a random element from any iterable
extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

//creating a cubit that get random name from list
class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);

//[emit] produce the state
  void pickRandomName() => emit(names.getRandomElement());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final NamesCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = NamesCubit();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyHomePage"),
      ),
      body: StreamBuilder<String?>(
        stream: cubit.stream,
        builder: (context, snapshot) {
          final button = TextButton(
            child: const Text(
              "Pick random name",
            ),
            onPressed: () => cubit.pickRandomName(),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return button;

            case ConnectionState.waiting:
              return button;

            case ConnectionState.active:
              return Column(
                children: [
                  Text(snapshot.data ?? " "),
                  button,
                ],
              );
            case ConnectionState.done:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
