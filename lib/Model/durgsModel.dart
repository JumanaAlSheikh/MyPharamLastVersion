import 'dart:ffi';

import 'package:flutter/material.dart';

class durgsModel {
  durgsList durgs;

  durgsModel(
      {this.durgs,
    });

  factory durgsModel.fromJson(Map<String, dynamic> json) {
    return durgsModel(
      durgs: durgsList.fromJson(json["drugs"]),
    );

  }
}
class durgsList {
  List<durgsAllList> listdurgs;
  durgsList({@required this.listdurgs});

  factory durgsList.fromJson(List<dynamic> json) {
    return durgsList(

        listdurgs: json.map((i) => durgsAllList.fromJson(i)).toList());
  }
}

class durgsAllList {
  String id;
  String CommerceName,ScientificName,Strengths,Price,Category,Manufacture,Icon,form;

  durgsAllList(
      {@required this.id,
        @required this.CommerceName,this.ScientificName,this.Strengths,this.Price,this.Category,this.Manufacture,this.Icon,this.form
      });


  factory durgsAllList.fromJson(Map<String, dynamic> json) {
    return durgsAllList(
      id: json['Id'].toString(),
      CommerceName: json['CommerceName'],
      ScientificName: json['ScientificName'],
      Strengths: json['Strengths'].toString(),
      Price: json['Price'].toString(),
      Category: json['Category'],
      Manufacture: json['Manufacture'],
      Icon: json['Icon'],
      form: json['Form'],


    );
  }
}