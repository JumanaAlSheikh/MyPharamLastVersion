import 'dart:ffi';

import 'package:flutter/material.dart';

class ManfModelHome {
  ManfListHome manfHome;

  ManfModelHome(
      {this.manfHome,
      });

  factory ManfModelHome.fromJson(Map<String, dynamic> json) {
    return ManfModelHome(
      manfHome: ManfListHome.fromJson(json["Manufactures"]),

    );
  }
}
class ManfListHome {
  List<manfsHome> listmanfHome;
  ManfListHome({@required this.listmanfHome});

  factory ManfListHome.fromJson(List<dynamic> json) {
    return ManfListHome(

        listmanfHome: json.map((i) => manfsHome.fromJson(i)).toList());
  }
}

class manfsHome {
  String id;
  String manfName,address,long,lat,phone,cityid,city,icon,status,createDate;

  manfsHome(
      {@required this.id,
        @required this.manfName,this.address,this.long,this.lat,this.phone,this.cityid,this.city,this.createDate,this.icon,this.status
      });


  factory manfsHome.fromJson(Map<String, dynamic> json) {
    return manfsHome(
      id: json['Id'].toString(),
      manfName: json['Name'],
      address: json['Address'],
      long: json['Longitude'].toString(),
      lat: json['Latidude'].toString(),
      phone: json['Phones'].toString(),
      cityid: json['CityId'].toString(),
      icon: json['Icon'],
      city: json['City'],
      createDate: json['CreateDate'],
      status: json['Status'].toString(),


    );
  }
}