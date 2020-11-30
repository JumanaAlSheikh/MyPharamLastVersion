



import 'package:pharmas/Model/offerListModel.dart';

class offerResponse {
  final String code;
  final offerModel results;
  final String msg;
  final int totalCount;

  offerResponse(this.results, this.code, this.msg,this.totalCount );

  offerResponse.fromJson(Map<String, dynamic> json)
      : results = offerModel.fromJson(json["data"]),

        code = json["code"],
        totalCount = json['totalCount'],

        msg = json['message'];

  offerResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount =0,

        msg = "";
}
