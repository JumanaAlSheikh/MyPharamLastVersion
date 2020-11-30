import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:pharmas/Model/storeDrugDetails.dart';
import 'package:pharmas/Model/offerStoreDetails.dart';


class storeModelDetails {
  String id;
  String storeName,cityId,address,phones,long,lat,city,createDate,status;
  drugStoreList drugList;
  offerStoreList offerList;





  // "stores": []
  storeModelDetails(
      {@required this.id,this.offerList,
        @required this.storeName,this.phones,this.address,this.city,this.status,this.createDate,this.cityId,this.lat,this.long,this.drugList
      });


  factory storeModelDetails.fromJson(Map<String, dynamic> json) {
    return storeModelDetails(
      id: json['Id'].toString(),
      storeName: json['Name'],
      phones: json['Phones'].toString(),
      address: json['Address'].toString(),
      long: json['Longitude'].toString(),
      lat: json['Latitude'].toString(),
      cityId: json['CityId'].toString(),
      city: json['City'],
      createDate: json['CreateDate'],
      status: json['Status'].toString(),
      drugList : drugStoreList.fromJson(json["Drugs"]),
      offerList : offerStoreList.fromJson(json["offers"]),

    );
  }
}