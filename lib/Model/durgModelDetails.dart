import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:pharmas/Model/drugWareDetails.dart';



class durgsModelDetails {
  String id;
  String CommerceName,ScientificName,Strengths,Price,Category,Manufacture,Icon;
  drugWareDetails storeList;

 // "stores": []
  durgsModelDetails(
      {@required this.id,
        @required this.CommerceName,this.ScientificName,this.Strengths,this.Price,this.Category,this.Manufacture,this.Icon,this.storeList
      });


  factory durgsModelDetails.fromJson(Map<String, dynamic> json) {
    return durgsModelDetails(
      id: json['Id'].toString(),
      CommerceName: json['CommerceName'],
      ScientificName: json['ScientificName'],
      Strengths: json['Strengths'].toString(),
      Price: json['Price'].toString(),
      Category: json['Category'],
      Manufacture: json['Manufacture'],
      Icon: json['Icon'],
      storeList : drugWareDetails.fromJson(json["stores"]),


    );
  }
}