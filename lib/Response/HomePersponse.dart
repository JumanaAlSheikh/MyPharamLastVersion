



import 'package:pharmas/Model/homeManfModel.dart';
import 'package:pharmas/Model/homeOfferModel.dart';
import 'package:pharmas/Model/homePageModel.dart';

class HomeResponse {
  final String code;
  final durgsModelHome resultsDurg;
  final ManfModelHome resultsManf;
  final OfferModelHome resultsOffer;

  final String msg;
  final int totalCount;

  HomeResponse(this.resultsDurg,this.resultsManf,this.resultsOffer, this.code, this.msg,this.totalCount );

  HomeResponse.fromJson(Map<String, dynamic> json)
      : resultsDurg = durgsModelHome.fromJson(json["data"]),
        resultsManf = ManfModelHome.fromJson(json["data"]),
        resultsOffer = OfferModelHome.fromJson(json["data"]),
        code = json["code"],
        totalCount = json['totalCount'],

        msg = json['message'];

  HomeResponse.withError(String errorValue)
      : resultsDurg = null,
  resultsOffer=null,
  resultsManf=null,
        code = "-1",
        totalCount =0,

        msg = "";
}
