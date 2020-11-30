import 'dart:ffi';

import 'package:flutter/material.dart';






class offerStoreList {
  List<storeOfferModelDetail> listStoreOffer;
  offerStoreList({@required this.listStoreOffer});

  factory offerStoreList.fromJson(List<dynamic> json) {
    return offerStoreList(

        listStoreOffer: json.map((i) => storeOfferModelDetail.fromJson(i)).toList());
  }
}

class storeOfferModelDetail {
  String id;
  String NameD,Tprice,quantity,gift,discount,exDate,DreugExDate,man;
String wareId,wareN,drugf,Description,Notes,CreateDate,Price,NormalPrice;


  // "stores": []
  storeOfferModelDetail(
      {@required this.id,this.wareId,this.wareN,this.drugf,this.Description,this.Notes,this.CreateDate,this.Price,this.NormalPrice,
        @required this.quantity,this.discount,this.exDate,this.gift,this.NameD,this.Tprice,this.DreugExDate,this.man
      });


  factory storeOfferModelDetail.fromJson(Map<String, dynamic> json) {
    return storeOfferModelDetail(
      id: json['Id'].toString(),
      NameD: json['Durg'],
      exDate: json['ExpiryDate'].toString(),
      quantity: json['Quantity'].toString(),
      gift: json['Gift'].toString(),
      discount: json['Discount'].toString(),
      Tprice:  json['TotalPrice'].toString(),
      wareId:  json['WarehouseId'].toString(),
      NormalPrice: json['NormalPrice'].toString(),

wareN: json['Warehouse'].toString(),
      drugf:json['DurgForm'].toString(),
        Description:json['Description'].toString(),
      Notes:json['Notes'].toString(),
        CreateDate:json['CreateDate'].toString(),
      Price: json['Price'].toString(),
        man: json["Manufacture"].toString(),

DreugExDate: json['DrugExpiryDate'].toString()
    );
  }
}
