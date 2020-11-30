


import 'package:pharmas/ApiProvider/homeApiProvider.dart';
import 'package:pharmas/Response/HomePersponse.dart';
import 'package:pharmas/Response/checkResponse.dart';import 'package:pharmas/Response/loginResponse.dart';


class HomeRepository {
  HomeApiProvider _apiProvider = HomeApiProvider();

  Future<HomeResponse> getHomeList(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getHomeList(sessionId,data,lang);

  }
  Future<loginResponse> setToken(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.setToken(sessionId,data,lang);

  }



  Future<checkResponse> checkForUpdate(String sessionId,String versionC,String lang) {
    return _apiProvider.checkForUpdate(sessionId,versionC,lang);

  }




}