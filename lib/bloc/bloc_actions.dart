//Event class for bloc
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc_practice/bloc/person.dart';

//defining url
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

const persons1Url = 'http://192.168.240.191:5500/api/persons1.json';
const persons2Url = 'http://192.168.240.191:5500/api/persons2.json';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

//first event
@immutable
class LoadPersonsAction implements LoadAction {
  final String url;
  final PersonsLoader loader;
  const LoadPersonsAction({required this.url, required this.loader}) : super();
}
