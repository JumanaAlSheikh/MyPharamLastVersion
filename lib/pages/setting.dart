import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/loginResponse.dart';
import 'package:pharmas/changePass.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/LocalHelper.dart';
import 'package:pharmas/pages/aboutPage.dart';

import 'package:pharmas/pages/Durgs/durgsList.dart';
import 'package:pharmas/pages/Pharma/PharmaListPage.dart';
import 'package:pharmas/pages/homePage.dart';
import 'package:pharmas/pages/profile.dart';
import 'package:pharmas/pages/register.dart';
import 'package:pharmas/pages/splashActivity.dart';
import 'package:pharmas/pages/verifyCode.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'forgetPassword.dart';

class setting extends StatefulWidget {
  @override
  _setting createState() => new _setting();
}

class _setting extends State<setting> {
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
  }
  onLocaleChange(Locale locale) {
    _specificLocalizationDelegate = new SpecificLocalizationDelegate(locale);
  }
  @override
  Widget build(BuildContext context) {
    helper.onLocaleChanged = onLocaleChange;

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            AppLocalizations().lbSet,
          ),
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Column(
                children: <Widget>[
                  GestureDetector(onTap:  (){showDialog(
                      context: context,
                      builder: (
                          BuildContext context) {
                        return showDialogLang(
                        );
                      });
                    },child:   Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          AppLocalizations().lbChangeL,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                        new Spacer(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey,
                            size: 27,
                          ),
                        )
                      ],
                    ),
                  ),),

                  Divider(
                    color: Colors.grey,
                    height: 1,
                  ),

                  GestureDetector(child:  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: GestureDetector(child:
                    Row(
                      children: <Widget>[
                        Text(
                         AppLocalizations().lbChangeP,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                        new Spacer(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey,
                            size: 27,
                          ),
                        )
                      ],
                    ),onTap: (){
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => Directionality(
                            textDirection:
                            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                            child:changeP()),
                        ),
                      );
                    },),
                  ),onTap: (){
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => Directionality(
                          textDirection:
                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                          child:changeP()),
                      ),
                    );
                  },),

                  Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                  GestureDetector(child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          AppLocalizations().lbAbout,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                        new Spacer(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey,
                            size: 27,
                          ),
                        )
                      ],
                    ),
                  ),onTap: (){
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => Directionality(
                            textDirection:
                            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                            child:aboutP()),
                      ),
                    );
                  },),
                  Divider(
                    color: Colors.grey,
                    height: 1,
                  ),


                  GestureDetector(child:  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: GestureDetector(child:
                    Row(
                      children: <Widget>[
                        Text(
                          AppLocalizations().lbPro,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                        new Spacer(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey,
                            size: 27,
                          ),
                        )
                      ],
                    ),onTap: (){
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => Directionality(
                            textDirection:
                            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                            child:profile()),
                        ),
                      );
                    },),
                  ),onTap: (){
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => Directionality(
                          textDirection:
                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                          child:profile()),
                      ),
                    );
                  },),
                  Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
                    child: GestureDetector(
                        onTap: () {


                          showDialog(
                              context: context,
                              builder: (
                                  BuildContext context) {
                                return showDialogwindowDeleteOffer(
                                   );
                              });

                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Center(
                              child: Text(
                                AppLocalizations().lbLog,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Colors.praimarydark),
                        )),
                  )
                ],
              ),
            ),
          ),
        ));
  }



  _buildSubmitForm(BuildContext context) async {



    var preferences = await SharedPreferences.getInstance();

    preferences.remove('sessionId');




      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>Directionality(
        textDirection:
        langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Splash())
          ),
          ModalRoute.withName("/Home")
      );


  }
  Widget showDialogwindowDeleteOffer() {
    return
AlertDialog(
  contentPadding: EdgeInsets.zero,

      content:SingleChildScrollView(child:  Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill)),
    child:Column(children: <Widget>[

      Padding(padding: EdgeInsets.all(20),child:Text(AppLocalizations().lbLog,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.praimarydark),),),

      Padding(padding: EdgeInsets.all(10),child: Text(AppLocalizations().lbLogM),),
        Row(children: <Widget>[
          Padding(padding: EdgeInsets.all(10),child: OutlineButton(
            color: Colors.yellow,
            focusColor: Colors.yellow,
            hoverColor: Colors.yellow,
            highlightColor: Colors.yellow,
            borderSide: BorderSide(color: Colors.praimarydark, width: 1),
            disabledBorderColor: Colors.yellow,
            child: new Text(AppLocalizations().lbCancel,style: TextStyle(color: Colors.praimarydark),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),),
          Padding(padding: EdgeInsets.all(10),child:  OutlineButton(
            color: Colors.yellow,
            focusColor: Colors.yellow,
            hoverColor: Colors.yellow,
            highlightColor: Colors.yellow,
            borderSide: BorderSide(color: Colors.praimarydark, width: 1),
            disabledBorderColor: Colors.yellow,
            child: new Text(AppLocalizations().lbOk,style: TextStyle(color: Colors.praimarydark),),
            onPressed: () async {

              _buildSubmitForm(context);

              //  GeneralResponse response = await _repository.addProjectRevnue(data);

            },
          ),)


        ],mainAxisAlignment: MainAxisAlignment.spaceBetween,)],)),),

    );
  }


  Widget showDialogLang() {
    return
      AlertDialog(
        contentPadding: EdgeInsets.zero,

        content:SingleChildScrollView(child:  Container(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill)),
            child:Column(children: <Widget>[

              Padding(padding: EdgeInsets.all(20),child:Text(AppLocalizations().lbChangeL,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.praimarydark),),),



              GestureDetector(child:Padding(padding: EdgeInsets.all(10),child: Text('English'),),
                  onTap: () async {
                    var preferences = await SharedPreferences.getInstance();

                    AppLocalizations().locale == 'en';
                    helper.onLocaleChanged(new Locale("en"));
                    AppLocalizations.load(new Locale("en"));
                    preferences.setString('lang', 'en');

                    preferences.remove('sessionId');




                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>Directionality(
                                textDirection:
                                langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                child: Splash())
                        ),
                        ModalRoute.withName("/Home")
                    );

                  }),

                GestureDetector(child:Padding(padding: EdgeInsets.all(10),child: Text('العربية'),),
                  onTap: () async {
                    String lang = AppLocalizations().locale;
                    var preferences = await SharedPreferences.getInstance();

// Save a value

                    AppLocalizations().locale == 'ar';
                    helper.onLocaleChanged(new Locale("ar"));
                    AppLocalizations.load(new Locale("ar"));
                    preferences.setString('lang', 'ar');



                    preferences.remove('sessionId');




                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>Directionality(
                                textDirection:
                                langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                child: Splash())
                        ),
                        ModalRoute.withName("/Home")
                    );

                  },),

           ],)),),

      );
  }

}
