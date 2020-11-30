import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmas/Repository/offerRepository.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:intl/intl.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/storelistdy.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pharmas/Model/alarm.dart';

import 'package:shared_preferences/shared_preferences.dart';

class reminderList extends StatefulWidget {
  @override
  _reminderList createState() => new _reminderList();
}

class _reminderList extends State<reminderList> {
  String sessionId, alarmL,orderSu;
  var preferences;
  var fromdate = GlobalKey<FormState>();
  final dateFormat = DateFormat("dd-MM-yyyy");
  String dateD;
  ProgressDialog pr;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
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

  List<Alarm> alarmLi;
  delete(List<Alarm> alarmLih, int index) async {
    alarmLih.removeAt(index);
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    String last = json.encode(
      alarmLih.map<Map<String, dynamic>>((music) => Alarm.toMap(music)).toList(),
    );
    print(last);
    sharedPrefs.setString('alamL', last);
    getValueString();
  }
  getValueString() async {

    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    setState(() {
      alarmL = preferences.getString('alamL');

      alarmLi = (json.decode(alarmL) as List<dynamic>)
          .map<Alarm>((item) => Alarm.fromJson(item))
          .toList();

    });
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
    pr = new ProgressDialog(context);
    pr.update(
      progress: 50.0,
      message: AppLocalizations().lbWait,
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(valueColor:
      new AlwaysStoppedAnimation<Color>(
          Colors.praimarydark))),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: new Text(
            AppLocalizations().lbAlarm,
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        //   resizeToAvoidBottomPadding: true,
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: alarmLi==null?Center(child:Container(child:Text(AppLocalizations().lbNoAlarm))):ListView.builder(
                    itemCount: alarmLi.length,
                    // Add one more item for progress indicator
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    itemBuilder: (BuildContext context, int index) {
                      return new Padding(
                          padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              alarmLi[index].drugN,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,color: Colors.praimarydark),
                                            ),new Spacer(),
                                            GestureDetector(child: Icon(Icons.delete,color: Colors.praimarydark,),
                                            onTap: (){
                                         delete(alarmLi,index);
                                            },)
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              alarmLi[index].ownerD,

                                            )
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              AppLocalizations().lbRemAt+' : ' + alarmLi[index].time,

                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                              Divider(
                                height: 1,
                                color: Colors.grey,
                              ),

                            ],
                          ));
                    },
                  )),
            ],
          ),
        ));
  }




}
