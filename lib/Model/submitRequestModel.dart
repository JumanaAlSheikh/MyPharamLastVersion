import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:pharmas/Model/orderModel.dart';

class submitList {
  subList subs;

  submitList(
      {this.subs,
      });

  factory submitList.fromJson(Map<String, dynamic> json) {
    return submitList(
      subs: subList.fromJson(json["Orders"]),

    );
  }
}
class subList {
  List<requestModel> reqList;
  subList({@required this.reqList});

  factory subList.fromJson(List<dynamic> json) {
    return subList(

        reqList: json.map((i) => requestModel.fromJson(i)).toList());
  }
}

class requestModel {
  String id;
  String deDate,wareId,wareName,reqType,creDate,requestStatus,city,reqPrice;
  orderModelList orderList;



  // "stores": []
  requestModel(
      {@required this.id,this.wareId,
        @required this.wareName,this.creDate,this.deDate,this.city,this.reqPrice,this.reqType,this.requestStatus,
      this.orderList
      });

  factory requestModel.fromJson(Map<String, dynamic> json) {
    return requestModel(
      id: json['Id'].toString(),
      deDate: json['DeliveryDate'],
      wareId: json['WarehouseId'].toString(),
      wareName: json['Warehouse'].toString(),
      reqType: json['RequestType'].toString(),
      creDate: json['CreateDate'].toString(),
      requestStatus: json['RequestStatus'].toString(),
      city: json['City'],
      reqPrice: json['RequestPrice'].toString(),
      orderList : orderModelList.fromJson(json["OrderItems"]),

    );
  }
}