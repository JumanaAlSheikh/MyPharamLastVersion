



import 'package:pharmas/Model/warehouseModel.dart';

class WareResponse {
  final String code;
  final wareModel results;
  final String msg;
  final int totalCount;

  WareResponse(this.results, this.code, this.msg,this.totalCount );

  WareResponse.fromJson(Map<String, dynamic> json)
      : results = wareModel.fromJson(json["data"]),

        code = json["code"],
        totalCount = json['totalCount'],

        msg = json['message'];

  WareResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount =0,

        msg = "";
}
