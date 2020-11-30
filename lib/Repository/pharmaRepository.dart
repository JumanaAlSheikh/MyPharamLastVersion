

import 'package:pharmas/ApiProvider/pharmaApiProvider.dart';
import 'package:pharmas/Response/pharmaResponse.dart';
import 'package:pharmas/Response/durgDetailsResponse.dart';

class PharmaRepository {
  PharmasApiProvider _apiProvider = PharmasApiProvider();

  Future<PharmaResponse> gerPharmaList(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.gerPharmaList(sessionId,data,lang);

  }
/*
  Future<durgDetailsResponse> getDurgDetails(String sessionId,Map<String, dynamic> data) {
    return _apiProvider.getDurgDetails(sessionId,data);

  }*/



}