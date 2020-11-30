

import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:rxdart/rxdart.dart';

class cityBloc {
  final CityRepository _repository = CityRepository();
  final BehaviorSubject<CityResponse> _subject =
  BehaviorSubject<CityResponse>();

  getCity(String lang) async {
    print("before get the get med resonse");

    CityResponse response = await _repository.getCity(lang);
    _subject.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }


  dispose() {
    _subject.close();
  }

  BehaviorSubject<CityResponse> get subject => _subject;

}

final blocCity= cityBloc();