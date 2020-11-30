

import 'package:pharmas/Repository/HomeRepository.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/HomePersponse.dart';
import 'package:pharmas/Response/checkResponse.dart';
import 'package:pharmas/Response/loginResponse.dart';
import 'package:rxdart/rxdart.dart';

class homeBloc {
  final HomeRepository _repository = HomeRepository();
  final BehaviorSubject<HomeResponse> _subject =
  BehaviorSubject<HomeResponse>();


  final BehaviorSubject<checkResponse> _subjectCheck =
  BehaviorSubject<checkResponse>();

  final BehaviorSubject<loginResponse> _subjectPro =
  BehaviorSubject<loginResponse>();

  final CityRepository _repositoryPro = CityRepository();

  getHomeList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    HomeResponse response = await _repository.getHomeList(sessionId, data,lang);
    _subject.sink.add(response);



  }
  setToken(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    loginResponse response = await _repository.setToken(sessionId, data,lang);
    _subjectPro.sink.add(response);



  }


  checkForUpdate(String sessionId,String versionC,String lang) async {
    print("before get the get med resonse");

    checkResponse response = await _repository.checkForUpdate(sessionId,versionC,lang);
    _subjectCheck.sink.add(response);



  }



  getMyPro(String sessionId,String lang) async {
    print("before get the get med resonse");

    loginResponse response = await _repositoryPro.getMyProfile(sessionId,lang);
    _subjectPro.sink.add(response);



  }
  dispose() {
    _subject.close();
    _subjectPro.close();
    _subjectCheck.close();

  }

  BehaviorSubject<HomeResponse> get subject => _subject;
  BehaviorSubject<loginResponse> get subjectPro => _subjectPro;
  BehaviorSubject<checkResponse> get subjectCheck => _subjectCheck;

}

final blocHome= homeBloc();