
import 'package:pharmas/Model/cityModel.dart';

class CityResponse {
  final String code;
  final CityModel results;
  final String msg;

  CityResponse(this.results, this.code, this.msg );

  CityResponse.fromJson(Map<String, dynamic> json)
      : results = CityModel.fromJson(json["data"]),

        code = json["code"],
        msg = json['message'];

  CityResponse.withError(String errorValue)
      : results = null,
        code = "-1",
        msg = "";

}
