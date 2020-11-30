import 'dart:ffi';

import 'package:flutter/material.dart';

class OfferModelHome {
  OfferListHome offerHome;

  OfferModelHome(
      {this.offerHome,
      });

  factory OfferModelHome.fromJson(Map<String, dynamic> json) {
    return OfferModelHome(
      offerHome: OfferListHome.fromJson(json["Ads"]),

    );
  }
}
class OfferListHome {
  List<offerHome> listofferHome;
  OfferListHome({@required this.listofferHome});

  factory OfferListHome.fromJson(List<dynamic> json) {
    return OfferListHome(

        listofferHome: json.map((i) => offerHome.fromJson(i)).toList());
  }
}

class offerHome {
  String id;
  String offerName,type,typeName,warename,drugname,price;

  offerHome(
      {@required this.id,
        @required this.offerName,this.type,this.typeName,this.price,this.drugname,this.warename,
      });


  factory offerHome.fromJson(Map<String, dynamic> json) {
    return offerHome(
      id: json['Id'].toString(),
      offerName: json['Name'],
      type: json['Type'].toString(),
      typeName: json['TypeName'].toString(),
      warename: json['WarehouseName'].toString(),
      price: json['OfferPrice'].toString(),
      drugname: json['DrugName'].toString(),


    );
  }
}