


import 'package:pharmas/Model/pharmaListModel.dart';

class PharmaResponse {
  final String code;
  final pharmaModel results;
  final String msg;
  final int totalCount;

  PharmaResponse(this.results, this.code, this.msg,this.totalCount );

  PharmaResponse.fromJson(Map<String, dynamic> json)
      : results = pharmaModel.fromJson(json["data"]),

        code = json["code"],
        totalCount = json['totalCount'],

        msg = json['message'];

  PharmaResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount =0,

        msg = "";
}
