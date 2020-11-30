

import 'package:pharmas/ApiProvider/compaonApiProvider.dart';
import 'package:pharmas/Response/CompainResponse.dart';

class CompainRepository {
  CompainApiProvider _apiProvider = CompainApiProvider();

  Future<CompainResponse> getcompainList(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getCompainList(sessionId,data,lang);

  }
/*
  Future<durgDetailsResponse> getDurgDetails(String sessionId,Map<String, dynamic> data) {
    return _apiProvider.getDurgDetails(sessionId,data);

  }*/



}