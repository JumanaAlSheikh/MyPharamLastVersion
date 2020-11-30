import 'package:flutter/material.dart';

class CityModel {
  final CityModel2 citiesr;

  CityModel({@required this.citiesr});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
        citiesr: CityModel2.fromJson(json["dropDownListItems"])
//        cityName: json['Name'],
      //  citiesr = json["dropDownListItems"],);

    );
       // citiesr = CityModel2.fromJson(json["dropDownListItems"]));
  }
}

class CityModel2 {
  List<City> cities;
  CityModel2({@required this.cities});

  factory CityModel2.fromJson(List<dynamic> json) {
    return CityModel2(

        cities: json.map((i) => City.fromJson(i)).toList());
  }
}

class City {
  int id;
  String cityName;
  bool check;

  City(
      {@required this.id,
        @required this.cityName,
        this.check
       });


  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityName: json['Name'],
      id: json['id'],


    );
  }
}
