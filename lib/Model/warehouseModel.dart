import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:pharmas/Model/storeDrugDetails.dart';

class wareModel {
  wareList wares;

  wareModel(
      {this.wares,
      });

  factory wareModel.fromJson(Map<String, dynamic> json) {
    return wareModel(
      wares: wareList.fromJson(json["Warehouses"]),

    );
  }
}
class wareList {
  List<waresAllList> listWare;
  wareList({@required this.listWare});

  factory wareList.fromJson(List<dynamic> json) {
    return wareList(

        listWare: json.map((i) => waresAllList.fromJson(i)).toList());
  }
}

class waresAllList {


  String id;
  String Name,Addres,Phones;
  drugStoreList drugList;

  waresAllList(
      {@required this.id,
        @required this.Name,this.Addres,this.Phones,this.drugList
      });


  factory waresAllList.fromJson(Map<String, dynamic> json) {
    return waresAllList(
      id: json['Id'].toString(),
      Name: json['Name'],
      Addres: json['Address'],
      Phones: json['Phones'].toString(),

      drugList : drugStoreList.fromJson(json["Drugs"]),

    );
  }
}