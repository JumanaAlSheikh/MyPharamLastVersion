import 'dart:ffi';

import 'package:flutter/material.dart';






class orderModelList {
  List<orderModelDetail> listOrder;
  orderModelList({@required this.listOrder});

  factory orderModelList.fromJson(List<dynamic> json) {
    return orderModelList(

        listOrder: json.map((i) => orderModelDetail.fromJson(i)).toList());
  }
}

class orderModelDetail {
  String id,Manufacture;
  String drugName,gift,quantity,offerId,offerDes,price,subPrice,SubTotalPrice;


  // "stores": []
  orderModelDetail(
      {@required this.id,
        @required this.quantity,this.gift,this.price,this.offerId,this.drugName,this.offerDes,this.subPrice,this.SubTotalPrice,this.Manufacture
      });


  factory orderModelDetail.fromJson(Map<String, dynamic> json) {
    return orderModelDetail(
      id: json['Id'].toString(),
      drugName: json['Drug'],
      gift: json['Gift'].toString(),
      quantity: json['Quantity'].toString(),
      offerId: json['OfferId'].toString(),
      offerDes: json['OfferDescription'].toString(),
      price: json['Price'].toString(),
      subPrice: json['SecondPrice'].toString(),
      Manufacture: json['Manufacture'].toString(),
      SubTotalPrice: json['SubTotalPrice'].toString(),



    );
  }
}
