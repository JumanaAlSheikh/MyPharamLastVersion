
import 'package:pharmas/Model/durgsModel.dart';

class DurgsResponse {
  final String code;
  final String msg;
  final int totalCount;
  final durgsModel results;

  DurgsResponse(this.code, this.msg, this.results, this.totalCount);

  DurgsResponse.fromJson(Map<String, dynamic> json)
      :
        results = durgsModel.fromJson(json["data"]),
        code = json["code"],
        msg = json['message'],
        totalCount = json['totalCount'];

  DurgsResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount = 0,
        msg = errorValue;
}
