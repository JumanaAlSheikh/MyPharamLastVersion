



import 'package:pharmas/Model/submitRequestModel.dart';

class reqResponse {
  final String code;
  final submitList results;
  final String msg;
  final int totalCount;

  reqResponse(this.results, this.code, this.msg,this.totalCount );

  reqResponse.fromJson(Map<String, dynamic> json)
      : results = submitList.fromJson(json["data"]),

        code = json["code"],
        totalCount = json['totalCount'],

        msg = json['message'];

  reqResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount =0,

        msg = "";
}
