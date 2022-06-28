import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_practice/bloc/bloc_actions.dart';
import 'package:flutter_bloc_practice/bloc/person.dart';
import 'package:flutter_bloc_practice/bloc/persons_bloc.dart';

void main() {
  runApp(MaterialApp(
    title: "Flutter demo",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: BlocProvider(create: (_) => PersonBloc(), child: const MyHomePage()),
  ));
}

// //defining url
// enum PersonUrl {
//   persons2,
//   persons1,
// }

// extension UrlString on PersonUrl {
//   String get urlString {
//     switch (this) {
//       case PersonUrl.persons1:
//         return 'http://192.168.240.191:5500/api/persons1.json';
//       case PersonUrl.persons2:
//         return 'http://192.168.240.191:5500/api/persons2.json';
//     }
//   }
// }

//equivalent to Http Get Request
Future<Iterable<Person>> getPerson(String url) => HttpClient()
    .getUrl(Uri.parse(url)) //http get request
    .then((req) => req.close()) //close get request
    .then((resp) =>
        resp.transform(utf8.decoder).join()) //convert response to string
    .then((str) =>
        json.decode(str) as List<dynamic>) //convert json string to List
    .then(
        (list) => list.map((e) => Person.fromJson(e))); // map element to person

//Person Bloc

//give null for out of bound index
extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    //access the content of  bloc using context.read
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(
                              url: persons1Url, loader: getPerson),
                        );
                  },
                  child: const Text("Load json #2")),
              TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(
                              url: persons2Url, loader: getPerson),
                        );
                  },
                  child: const Text("Load json #1")),
            ],
          ),
          BlocBuilder<PersonBloc, FetchResult?>(
              buildWhen: (previousResult, currentReslt) {
            return previousResult?.persons != currentReslt?.persons;
          }, builder: ((context, state) {
            final persons = state?.persons;
            if (persons == null) {
              return const SizedBox();
            }
            return Expanded(
                child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index]!;
                      return ListTile(
                        title: Text(person.name),
                      );
                    }));
          })),
        ],
      ),
    );
  }
}
