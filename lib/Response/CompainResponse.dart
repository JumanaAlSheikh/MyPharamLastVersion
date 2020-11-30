
import 'package:pharmas/Model/compainListModel.dart';

class CompainResponse {
  final String code;
  final String msg;
  final int totalCount;
  final compainModel results;

  CompainResponse(this.code, this.msg, this.results, this.totalCount);

  CompainResponse.fromJson(Map<String, dynamic> json)
      :
        results = compainModel.fromJson(json["data"]),
        code = json["code"],
        msg = json['message'],
        totalCount = json['totalCount'];

  CompainResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        totalCount = 0,
        msg = errorValue;
}
