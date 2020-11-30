import 'dart:ffi';

import 'package:flutter/material.dart';

class offerModel {
  offerLists offers;

  offerModel(
      {this.offers,
      });

  factory offerModel.fromJson(Map<String, dynamic> json) {
    return offerModel(
      offers: offerLists.fromJson(json["offers"]),

    );
  }
}
class offerLists {
  List<offerAllList> listOffer;
  offerLists({@required this.listOffer});

  factory offerLists.fromJson(List<dynamic> json) {
    return offerLists(

        listOffer: json.map((i) => offerAllList.fromJson(i)).toList());
  }
}

class offerAllList {

  int id,WarehouseId;
  String Description,DurgId,Durg,DurgForm,Quantity,Price,Duration,Warehouse,CreateDate,
  Status,Gift,Notes,ExpiryDate,Discount,TotalPrice,NormalPrice,mane,drugExDa;

  offerAllList(
      {@required this.id,
        @required this.Price,this.Description,this.Discount,this.Duration,this.Durg,this.DurgForm,
        this.DurgId,this.Status,this.ExpiryDate,this.Gift,this.CreateDate,this.NormalPrice,this.Notes,
        this.Quantity,this.TotalPrice,this.Warehouse,this.WarehouseId,this.mane,this.drugExDa
      });


  factory offerAllList.fromJson(Map<String, dynamic> json) {
    return offerAllList(
      id: json['Id'],
      Price: json['Price'].toString(),
      Description: json['Description'],
      Discount: json['Discount'].toString(),
      Duration: json['Duration'].toString(),
      Durg: json['Durg'].toString(),
      DurgForm: json['DurgForm'].toString(),
      DurgId: json['DurgId'].toString(),
      Status: json['Status'].toString(),
      ExpiryDate: json['ExpiryDate'].toString(),
      Gift: json['Gift'],
      CreateDate: json['CreateDate'],
      NormalPrice: json['NormalPrice'].toString(),
      Notes: json['Notes'],
      Quantity: json['Quantity'].toString(),
      TotalPrice: json['TotalPrice'].toString(),
      Warehouse: json['Warehouse'],
      WarehouseId: json['WarehouseId'],
      mane: json['Manufacture'],
      drugExDa: json['DrugExpiryDate'],



    );
  }
}