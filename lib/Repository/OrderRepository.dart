

import 'package:pharmas/ApiProvider/reqApiProvider.dart';
import 'package:pharmas/Response/requestResponse.dart';

class OrderRepository {
  ReqApiProvider _apiProvider = ReqApiProvider();

  Future<reqResponse> getOrderList(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getOrderReqList(sessionId,data,lang);

  }
/*
  Future<durgDetailsResponse> getDurgDetails(String sessionId,Map<String, dynamic> data) {
    return _apiProvider.getDurgDetails(sessionId,data);

  }*/



}