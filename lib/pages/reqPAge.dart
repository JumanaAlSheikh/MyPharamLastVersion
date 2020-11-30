import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Bloc/blocOffer.dart';
import 'package:pharmas/Bloc/blocOrder.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Model/submitRequestModel.dart';
import 'package:pharmas/Repository/OrderRepository.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/requestResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/offers/offerDetailsPage.dart';
import 'package:pharmas/ScrollingText.dart';
import 'package:pharmas/pages/requestDetails.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class reqList extends StatefulWidget {
  @override
  _reqList createState() => new _reqList();
}

class _reqList extends State<reqList> {
  List<requestModel> offerList;
  int page = 2;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  List<requestModel> tList;
  List<requestModel> tListall;
  TextEditingController editingController = TextEditingController();
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  String sessionId;
  var preferences;
  reqResponse response;
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  var items = List<requestModel>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  getValueString() async {

    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');

    Map<String, dynamic> data = {
      "PageSize": 10,
      "PageNumber": 1,
      "Filter": -1,
      "Search": "",
    };
   // blocOrder.getOrderList(sessionId, data);

    final OrderRepository _repository = OrderRepository();

    response = await _repository.getOrderList(sessionId, data,langSave);
    setState(() {
      tListall = response.results.subs.reqList;
      items.addAll(tListall);

    });
  }
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  Future navigationPage() async {
    var preferences = await SharedPreferences.getInstance();

    langSave = preferences.getString('lang');
    print("lang saved == $langSave");
    //langSave=lang1;
    if (langSave == 'ar') {
      _specificLocalizationDelegate =
          SpecificLocalizationDelegate(new Locale("ar"));

      AppLocalizations.load(new Locale("ar"));


    } else {
      _specificLocalizationDelegate =
          SpecificLocalizationDelegate(new Locale("en"));
      AppLocalizations.load(new Locale("en"));


    }
  }
  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {


        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'repeatDailyAtTime channel id',
          'repeatDailyAtTime channel name',
          'repeatDailyAtTime description',
          //  icon: 'assets/images/logo.png',

          importance: Importance.Max,
          priority: Priority.High,   styleInformation: DefaultStyleInformation(true, true),);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          message['notification']['title'],
          message['notification']['body'],
          platformChannelSpecifics,
          payload: 'Test Payload',);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
      });
    });
    navigationPage();
    getValueString();
    //  _getMoreData(page);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });
    //  navigationPage();
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      leading: GestureDetector(
        child: Icon(Icons.arrow_back_ios),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(AppLocalizations().lbMyOre),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _appBar(),
        //   resizeToAvoidBottomPadding: true,
        body: tListall == null
            ? Container()
            : ListView.builder(
                itemCount: tListall.length + 1,
                // Add one more item for progress indicator
                padding: EdgeInsets.symmetric(vertical: 8.0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == tListall.length) {
                    return _buildProgressIndicator();
                  } else {
                    return new Padding(
                      padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                      child: GestureDetector(child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            image: DecorationImage(
                                image: AssetImage('assets/images/offerd.png'),
                                fit: BoxFit.cover)),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Row(children: <Widget>[Text(
                                tListall[index].wareName,
                                style: TextStyle(
                                    color: Colors.praimarydark,
                                    fontWeight: FontWeight.bold),
                              ),new Spacer(),
                                Text(
                                  AppLocalizations().lbOreberN+' : '+ tListall[index].id.split('.')[0],
                                )],),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    AppLocalizations().lbCreDate+' : ' + tListall[index].creDate.substring(0,10),
                                  ),
                                  new Spacer(),
                                  Text(tListall[index].requestStatus == '1'
                                      ? AppLocalizations().lbStatus+': '+AppLocalizations().lbPending
                                      : tListall[index].requestStatus == '2'
                                      ? AppLocalizations().lbStatus+': '+ AppLocalizations().lbProcessing
                                      : tListall[index].requestStatus == '3'
                                      ? AppLocalizations().lbStatus+': '+ AppLocalizations().lbDone
                                      :  AppLocalizations().lbStatus+': '+ AppLocalizations().lbRej)
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    AppLocalizations().lbToPrice+' : ' + tListall[index].reqPrice,
                                  ),
                                  new Spacer(),
                                  tListall[index].orderList.listOrder.length == null
                                      ? Visibility(
                                    child: Text('Details'),
                                    visible: false,
                                  )
                                      : Visibility(
                                    child: Padding(
                                      padding:
                                      EdgeInsets.fromLTRB(20, 10, 20, 10),
                                      child: Container(

                                        child: Text(AppLocalizations().lbOrders,style: TextStyle(fontWeight: FontWeight.bold,
                                        color: Colors.red),),
                                      ),
                                    ),
                                    visible: true,
                                  )

                                ],
                              ),
                            ),


                          ],
                        ),
                      ),

                      onTap: (){
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                Directionality(
                                    textDirection:
                                    langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                    child:reqDetails(  tListall[index])),
                          ),
                        );
                      },),
                    );
                  }
                },

                controller: _sc,
              ));
  }

  _getMoreData(int index) async {
    tList = new List();
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      Map<String, dynamic> data = {
        "PageSize": 10,
        "PageNumber": page,
        "Filter": -1,
        "Search": "",
      };
      final OrderRepository _repository = OrderRepository();

      response = await _repository.getOrderList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
      //   response = blocOffer.getOfferList(sessionId, data);
      if (response.code == '1') {
        for (int i = 0; i <= response.results.subs.reqList.length; i++) {
          tList = new List.from(response.results.subs.reqList);
          //  tList.add(offerList[i]);
        }

        setState(() {
          isLoading = false;
          //  offerList.addAll(tList);
          //  offerList= new List.from(tList,tListall);
          if (tListall == null) {
            tListall = offerList + tList;
          } else {
            tListall = tListall + tList;
          }

          page++;
        });
      }else{
        Toast.show(
            response.msg.toString(),
            context,
            duration: 4,
            gravity: Toast.BOTTOM);
      }
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(valueColor:
          new AlwaysStoppedAnimation<Color>(
              Colors.praimarydark)),
        ),
      ),
    );
  }
}
