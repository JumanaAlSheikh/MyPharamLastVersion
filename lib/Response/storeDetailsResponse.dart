

import 'package:pharmas/Model/storeModelDetails.dart';

class storeDetailsResponse {
  final String code;
  final storeModelDetails results;
  final String msg;
  final int totalCount;

  storeDetailsResponse(this.results, this.code, this.msg,this.totalCount );

  storeDetailsResponse.fromJson(Map<String, dynamic> json)
      : results = storeModelDetails.fromJson(json["data"]),

        code = json["code"],
        totalCount = json['totalCount'],

        msg = json['message'];

  storeDetailsResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount =0,

        msg = "";
}
