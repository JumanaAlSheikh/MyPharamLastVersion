


import 'package:pharmas/ApiProvider/offerApiProvider.dart';
import 'package:pharmas/Response/offerResponse.dart';
import 'package:pharmas/Response/registerResponse.dart';

class offerRepository {
  offerApiProvider _apiProvider = offerApiProvider();

  Future<offerResponse> getOfferList(String sessionId,Map<String, dynamic> data,String lang) {
    return _apiProvider.getOfferList(sessionId,data,lang);

  }
  Future<registerResponse> submitOrderOffer(Map<String, dynamic> data,String sessionId,String lang) {
    return _apiProvider.submitOrderOffer(data,sessionId,lang);

  }



}