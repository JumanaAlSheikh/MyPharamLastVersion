

import 'package:dio/dio.dart';
import 'package:pharmas/ApiProvider/cityApiProvider.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/loginResponse.dart';
import 'package:pharmas/Response/registerResponse.dart';

class CityRepository {
  CityApiProvider _apiProvider = CityApiProvider();

  Future<CityResponse> getCity(String lang) {
    return _apiProvider.getCity(lang);

  }

  Future<registerResponse> register(Map<String, dynamic> data,String lang) {
    return _apiProvider.Register(data,lang);

  }
  Future<loginResponse> login(Map<String, dynamic> data,String lang) {
    return _apiProvider.login(data,lang);

  }


  Future<loginResponse> getMyProfile(String sessionId,String lang) {
    return _apiProvider.getMyProfile(sessionId,lang);

  }

  Future<registerResponse> verfyAccount(Map<String, dynamic> data,String lang) {
    return _apiProvider.VerfyAccount(data,lang);

  }
  Future<registerResponse> getCodeForget(Map<String, dynamic> data,String lang) {
    return _apiProvider.VerfyAccount(data,lang);

  }
  Future<registerResponse> changePass(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.changePas(sessionId,data,lang);

  }

  Future<registerResponse> ForgetPass(Map<String, dynamic> data,String lang) {
    return _apiProvider.ForgetPass(data,lang);

  }

}