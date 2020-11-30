import 'dart:ffi';

import 'package:flutter/material.dart';






class drugStoreList {
  List<storeDrugModelDetail> listStoreDrug;
  drugStoreList({@required this.listStoreDrug});

  factory drugStoreList.fromJson(List<dynamic> json) {
    return drugStoreList(

        listStoreDrug: json.map((i) => storeDrugModelDetail.fromJson(i)).toList());
  }
}

class storeDrugModelDetail {
  String id,name;
  String CommerceName,ScientificName,Strengths,Price,Category,Manufacture,Icon,pharmap,exdate,formD;


  // "stores": []
  storeDrugModelDetail(
      {@required this.id,this.name,
        @required this.CommerceName,this.ScientificName,this.Strengths,this.Price,this.Category,this.Manufacture,this.Icon,this.formD,
        this.pharmap,this.exdate
      });


  factory storeDrugModelDetail.fromJson(Map<String, dynamic> json) {
    return storeDrugModelDetail(
      id: json['Id'].toString(),
      CommerceName: json['CommerceName'],
      ScientificName: json['ScientificName'],
      Strengths: json['Strengths'].toString(),
      Price: json['Price'].toString(),
      Category: json['Category'],
      Manufacture: json['Manufacture'],
      Icon: json['Icon'],
      name: json['Name'],
      pharmap: json['SecondPrice'].toString(),
      exdate: json['DrugExpiryDate'],
      formD: json['Form'],


    );
  }
}