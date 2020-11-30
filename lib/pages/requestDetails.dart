import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Bloc/blocOffer.dart';
import 'package:pharmas/Bloc/blocOrder.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Model/orderModel.dart';
import 'package:pharmas/Model/submitRequestModel.dart';
import 'package:pharmas/Repository/OrderRepository.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/requestResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/offers/offerDetailsPage.dart';
import 'package:pharmas/ScrollingText.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class reqDetails extends StatefulWidget {
  final   requestModel tListall;
  reqDetails(this.tListall);

  @override
  _reqDetails createState() => new _reqDetails();
}

class _reqDetails extends State<reqDetails> {
 
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
    navigationPage();
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
  //  getValueString();
    //  _getMoreData(page);

   
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
      title: Text(widget.tListall.wareName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _appBar(),
        //   resizeToAvoidBottomPadding: true,
        body:  SingleChildScrollView(child: Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
          child: Container(
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
                    widget.tListall.wareName,
                    style: TextStyle(
                        color: Colors.praimarydark,
                        fontWeight: FontWeight.bold),
                  ),new Spacer(),
                    Text(
                      AppLocalizations().lbOreberN+' : '+ widget.tListall.id.split('.')[0],
                    )],),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations().lbCreDate+' : ' + widget.tListall.creDate.substring(0,10),
                      ),
                      new Spacer(),
                      Text(widget.tListall.requestStatus == '1'
                          ? AppLocalizations().lbStatus+': '+AppLocalizations().lbPending
                          : widget.tListall.requestStatus == '2'
                          ? AppLocalizations().lbStatus+': '+ AppLocalizations().lbProcessing
                          : widget.tListall.requestStatus == '3'
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
                        AppLocalizations().lbToPrice+' : ' + widget.tListall.reqPrice.split('.')[0],
                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    children: <Widget>[Text(AppLocalizations().lbOrders+' : ')],
                  ),
                ),
                widget.tListall.orderList.listOrder.length == null
                    ? Visibility(
                  child: Text('null'),
                  visible: false,
                )
                    : Visibility(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                      child: Container(
                          child: Wrap(
                            spacing: 0.0,
                            alignment: WrapAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding:
                                EdgeInsets.fromLTRB(2, 0, 2, 0),
                                child: Container(
                                  child: Directionality(
                                      textDirection:
                                      langSave == 'ar' ? TextDirection.ltr : TextDirection.ltr,
                                      child:_getBodyWidget(widget.tListall
                                          .orderList.listOrder)),
                                ),
                              )

                              /* GridView.count(
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,ssss
                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1 / 1.8,
                    crossAxisCount: 2,
//          primary: false,
                    children: List.generate(
                      model.notes.length,
                          (index) => ItemCardNote(model.notes[index]),
                    ),
                  )*/
                            ],
                          ))),
                  visible: true,
                )
              ],
            ),
          ),
        )),);
  }

  Widget _getBodyWidget(List<orderModelDetail> reportModel) {
    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 100,
        rightHandSideColumnWidth: 1000,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: reportModel.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
      ),
      height: MediaQuery.of(context).size.height,
    );
  }
  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.praimarydark)),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      //company name
      child: Text(widget.tListall.orderList.listOrder[index].Manufacture),
      width: 200,
      height: 100,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(widget.tListall.orderList.listOrder[index].drugName),

          width: 100,
          height: 100,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),

        Container(
          child: Text(widget.tListall.orderList.listOrder[index].quantity),
          width: 100,
          height: 100,
          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(widget.tListall.orderList.listOrder[index].price.split('.')[0]),
          width: 100,
          height: 100,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(widget.tListall.orderList.listOrder[index].subPrice.split('.')[0]),
          width: 100,
          height: 100,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(widget.tListall.orderList.listOrder[index].SubTotalPrice.split('.')[0]),
          width: 100,
          height: 100,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),

      ],
    );
  }
  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(AppLocalizations().lbComN, 100),
      _getTitleItemWidget(AppLocalizations().lbDrugN, 100),
      _getTitleItemWidget(AppLocalizations().lbQuan, 100),
      _getTitleItemWidget(AppLocalizations().lbGePrice, 100),
      _getTitleItemWidget(AppLocalizations().lbPhPrice, 100),
      _getTitleItemWidget(AppLocalizations().lbToPrice, 100),

    ];
  }

}
