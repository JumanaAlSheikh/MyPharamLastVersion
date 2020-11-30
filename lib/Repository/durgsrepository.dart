

import 'package:pharmas/ApiProvider/durgsApiProvider.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/durgsResponse.dart';
import 'package:pharmas/Response/durgDetailsResponse.dart';

class DurgsRepository {
  DurgsApiProvider _apiProvider = DurgsApiProvider();

  Future<DurgsResponse> getDurgsLisy(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getDurgsList(sessionId,data,lang);

  }

  Future<CityResponse> getCategoryList(String lang) {
    return _apiProvider.getCategoryList(lang);

  }
  Future<durgDetailsResponse> getDurgDetails(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getDurgDetails(sessionId,data,lang);

  }



}