import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MaterialApp(
    title: "Flutter demo",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: BlocProvider(create: (_) => PersonBloc(), child: const MyHomePage()),
  ));
}

//Event class for bloc
@immutable
abstract class LoadAction {
  const LoadAction();
}

//first event
@immutable
class LoadPersonsAction implements LoadAction {
  final PersonUrl url;
  const LoadPersonsAction({required this.url}) : super();
}

//defining url
enum PersonUrl {
  persons2,
  persons1,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return 'http://192.168.240.191:5500/api/persons1.json';
      case PersonUrl.persons2:
        return 'http://192.168.240.191:5500/api/persons2.json';
    }
  }
}

//model class person

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

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

// state for  bloc
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrivedFromCache;
  const FetchResult({
    required this.persons,
    required this.isRetrivedFromCache,
  });

  @override
  String toString() =>
      'FetchResult (isRetrivedFromCache = $isRetrivedFromCache, persons = $persons)';
}

//Person Bloc

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache =
      {}; //for cachng the url response
  //handle the LoadPersonsAction in the constructor
  PersonBloc() : super(null) {
    on<LoadPersonsAction>(((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        //we have the value in the cache
        final cachedPersons = _cache[url]!;
        final result = FetchResult(
          persons: cachedPersons,
          isRetrivedFromCache: true,
        );
        emit(result);
      } else {
        final persons = await getPerson(url.urlString);
        _cache[url] = persons;

        final result =
            FetchResult(persons: persons, isRetrivedFromCache: false);

        emit(result);
      }
    }));
  }
}

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
                            url: PersonUrl.persons1,
                          ),
                        );
                  },
                  child: const Text("Load json #2")),
              TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(
                            url: PersonUrl.persons2,
                          ),
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
              return SizedBox();
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
