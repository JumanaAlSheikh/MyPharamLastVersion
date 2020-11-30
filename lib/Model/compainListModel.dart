import 'dart:ffi';

import 'package:flutter/material.dart';

class compainModel {
  compainList compains;

  compainModel(
      {this.compains,
      });

  factory compainModel.fromJson(Map<String, dynamic> json) {
    return compainModel(
      compains: compainList.fromJson(json["manufactures"]),

    );
  }
}
class compainList {
  List<compainAllList> listcompain;
  compainList({@required this.listcompain});

  factory compainList.fromJson(List<dynamic> json) {
    return compainList(

        listcompain: json.map((i) => compainAllList.fromJson(i)).toList());
  }
}

class compainAllList {

  String id;
  String Icon,compainName,phones,Address,Longitude,Latidute,Status,CityId,City,
      CreateDate;

  compainAllList(
      {@required this.id,
        @required this.Icon,this.compainName,this.phones,this.Address,this.Longitude,this.Latidute,
        this.Status,this.CityId,this.City,this.CreateDate
      });


  factory compainAllList.fromJson(Map<String, dynamic> json) {
    return compainAllList(
      id: json['Id'].toString(),
      Icon: json['Icon'],
      compainName: json['Name'],
      phones: json['Phones'].toString(),
      Address: json['Address'].toString(),
      Longitude: json['Longitude'].toString(),
      Latidute: json['Latidute'].toString(),
      Status: json['Status'].toString(),
      CityId: json['CityId'].toString(),
      City: json['City'],
      CreateDate: json['CreateDate'],



    );
  }
}