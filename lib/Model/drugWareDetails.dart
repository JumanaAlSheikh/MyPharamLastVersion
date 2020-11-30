import 'dart:ffi';

import 'package:flutter/material.dart';






class drugWareDetails {
  List<storeDrugModelDetail> listStoreDrug;
  drugWareDetails({@required this.listStoreDrug});

  factory drugWareDetails.fromJson(List<dynamic> json) {
    return drugWareDetails(

        listStoreDrug: json.map((i) => storeDrugModelDetail.fromJson(i)).toList());
  }
}

class storeDrugModelDetail {
  String id;
  String nameStore;


  // "stores": []
  storeDrugModelDetail(
      {@required this.id,this.nameStore
      });


  factory storeDrugModelDetail.fromJson(Map<String, dynamic> json) {
    return storeDrugModelDetail(
      id: json['Id'].toString(),
      nameStore: json['Name'],



    );
  }
}
