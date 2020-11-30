



import 'package:pharmas/ApiProvider/wareApiProvider.dart';
import 'package:pharmas/Response/WareResponse.dart';
import 'package:pharmas/Response/storeDetailsResponse.dart';

class WareRepository {
  WaresApiProvider _apiProvider = WaresApiProvider();

  Future<WareResponse> getWareList(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getWareList(sessionId,data,lang);

  }
  Future<storeDetailsResponse> getStoreDetails(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getWareDetails(sessionId,data,lang);

  }



}