import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_practice/bloc/bloc_actions.dart';
import 'package:flutter_bloc_practice/bloc/person.dart';

//checking if  both length are equal and their intersections length is equal to length
extension IsEqualTOIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

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

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrivedFromCache == other.isRetrivedFromCache;

  @override
  int get hashCode => Object.hash(persons, isRetrivedFromCache);
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {}; //for cachng the url response
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
        final loader = event.loader;
        final persons = await loader(url);
        // final persons = await getPerson(url.urlString);
        _cache[url] = persons;

        final result =
            FetchResult(persons: persons, isRetrivedFromCache: false);

        emit(result);
      }
    }));
  }
}
