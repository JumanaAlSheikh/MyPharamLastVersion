import 'dart:ffi';

import 'package:flutter/material.dart';

class durgsModelHome {
  durgsListHome durgsHome;

  durgsModelHome(
      {this.durgsHome,
      });

  factory durgsModelHome.fromJson(Map<String, dynamic> json) {
    return durgsModelHome(
      durgsHome: durgsListHome.fromJson(json["Drugs"]),

    );
  }
}
class durgsListHome {
  List<durgsHome> listdurgsHome;
  durgsListHome({@required this.listdurgsHome});

  factory durgsListHome.fromJson(List<dynamic> json) {
    return durgsListHome(

        listdurgsHome: json.map((i) => durgsHome.fromJson(i)).toList());
  }
}

class durgsHome {
  String id;
  String CommerceName,ScientificName,Strengths,Price,Category,Manufacture,Icon;

  durgsHome(
      {@required this.id,
        @required this.CommerceName,this.ScientificName,this.Strengths,this.Price,this.Category,this.Manufacture,this.Icon
      });


  factory durgsHome.fromJson(Map<String, dynamic> json) {
    return durgsHome(
      id: json['Id'].toString(),
      CommerceName: json['CommerceName'],
      ScientificName: json['ScientificName'],
      Strengths: json['Strengths'].toString(),
      Price: json['Price'].toString(),
      Category: json['Category'],
      Manufacture: json['Manufacture'],
      Icon: json['Icon'],


    );
  }
}