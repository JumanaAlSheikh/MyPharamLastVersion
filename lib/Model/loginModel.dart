import 'dart:ffi';

import 'package:flutter/material.dart';





class User {

String phone,mobile;
  String id,cityId,LicenseNumber,Latidute,Longitude;
  String sessionId,
      email,
  Address,PharmacistName,
  PharmacyName,
     Status,City,CreateDate,WorkingHours,pharmaPic,SynNum,SynPic;

  User(
      { this.id,
      this.cityId,
        this.LicenseNumber,
        this.Latidute,
        this.Longitude,
        this.sessionId,
        this.email,
        this.Address,
        this.phone,this.mobile,
        this.PharmacistName,
        this.PharmacyName,this.Status,this.City,this.CreateDate,this.WorkingHours,this.pharmaPic,this.SynNum,this.SynPic});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'].toString(),
  cityId: json['CityId'].toString(),
  LicenseNumber: json['LicenseNumber'].toString(),
  Latidute: json['Latidute'].toString(),
  Longitude: json['Longitude'].toString(),
  sessionId: json['SessionId'],
  email: json['Email'],
  Address: json['Address'],
  PharmacistName: json['PharmacistName'],

  PharmacyName: json['PharmacyName'],
  Status: json['Status'].toString(),
  City: json['City'],
  CreateDate: json['CreateDate'],
  WorkingHours: json['WorkingHours'],
      pharmaPic: json['PharmacyPhoto'],
      SynNum : json['SyndicateNumber'].toString(),
      SynPic : json['SyndicateIdPhoto'],

      phone : json['Phone'].toString(),
      mobile : json['Mobile'].toString(),



    );
  }

}
