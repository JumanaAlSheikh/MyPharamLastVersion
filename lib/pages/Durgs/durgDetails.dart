import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pharmas/Bloc/blocDurgs.dart';
import 'package:pharmas/Model/durgModelDetails.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/storeDetailsPage.dart';
import 'package:pharmas/Response/durgDetailsResponse.dart';
import 'package:pharmas/Model/alarm.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rxdart/rxdart.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,

    @required this.payload,
  });
}
class durgDetails extends StatefulWidget {
  final String nameDurg;

  final String id;
  final String isStore;

  durgDetails(this.nameDurg, this.id,this.isStore);

  @override
  _durgsList createState() => new _durgsList();
}

class _durgsList extends State<durgDetails> {
  String sessionId;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  var preferences;
  final _ownerD = new TextEditingController();
  String fromTime;
  List<Alarm> gg = new List<Alarm>();

  String alarmL;
  List<Alarm> alarmLi;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var fromdate = GlobalKey<FormState>();
  DateFormat format;
  NotificationAppLaunchDetails notificationAppLaunchDetails;
  final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
  BehaviorSubject<ReceivedNotification>();
  final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();



  getValueString() async {
    WidgetsFlutterBinding.ensureInitialized();

    notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            debugPrint('notification payload: ' + payload);
          }
          selectNotificationSubject.add(payload);
        });
    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');

    Map<String, dynamic> data = {
      "Id": widget.id,
    };
    print(data);
    print(sessionId);
    blocDurgs.downloadData(sessionId, data,langSave);
  }
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
    initializeDateFormatting();
    format  =DateFormat("HH:mm");
    navigationPage();
    getValueString();

    //  navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nameDurg,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.praimarydark,
      ),
      resizeToAvoidBottomPadding: true,
      body: StreamBuilder<DownloadState>(
          stream: blocDurgs.dataState,
          // bloc get method that returns stream output.
          // initialData: DownloadState.NO_DOWNLOAD,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data) {
                case DownloadState.NO_DOWNLOAD:
                  return Center(
                    child: CircularProgressIndicator(valueColor:
                    new AlwaysStoppedAnimation<Color>(
                        Colors.praimarydark)),
                  );
                case DownloadState.DOWNLOADING:
                  return Center(
                    child: CircularProgressIndicator(valueColor:
                    new AlwaysStoppedAnimation<Color>(
                        Colors.praimarydark)),
                  );
                case DownloadState.SUCCESS:
                  return SingleChildScrollView(
                    child:  StreamBuilder(
                      stream: blocDurgs.subjectdetails.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<durgDetailsResponse> snapshot) {
                        if (snapshot.hasData) {
                          /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/
                          return new ListView(shrinkWrap: true,children: <Widget>[Padding(
                            padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    child: Container(
                                      child:

                                        Padding(
                                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot.data.results.CommerceName
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.praimarydark,
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.bold),
                                                    ),new Spacer(),
                                                    GestureDetector(child: Icon(Icons.add_alert, color: Colors.praimarydark,),onTap: (){


                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return showDialogwindowDone(
                                                                snapshot.data.results
                                                                    .CommerceName
                                                                    .toString());
                                                          });
                                                    },),
                                                  ],
                                                ),
                                              ),
                                              Divider(
                                                height: 1,
                                                color: Colors.grey,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot.data.results.Strengths
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 2, 0, 3),
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(child:Text(

                                                          snapshot.data.results.ScientificName
                                                              .toString(),
                                                          overflow: TextOverflow.ellipsis,

                                                          style:
                                                          TextStyle(color: Colors.grey),
                                                        ),width:300),
                                                      ],
                                                    ),
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          snapshot.data.results.Category
                                                              .toString(),
                                                          style:
                                                          TextStyle(color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          snapshot.data.results.Manufacture
                                                              .toString(),
                                                          style:
                                                          TextStyle(color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                           widget.isStore=='1'?Visibility(visible: true,child: Divider(
                                             color: Colors.grey,
                                             height: 1,
                                           ),):

                                           Visibility(visible: false,child: Divider(
                                             color: Colors.grey,
                                             height: 1,
                                           ),),

                                              widget.isStore=='1'?Visibility(visible: true,child:       Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                                  child: Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(10, 20, 10, 20),
                                                    child:  Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          AppLocalizations().lbAva,
                                                          style: TextStyle(
                                                              color: Colors.praimarydark,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15),
                                                        ),
                                                        new Spacer(),
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(
                                                              0, 3, 0, 0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down,
                                                            color: Colors.praimarydark,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),):

                                              Visibility(visible: false,child:      Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                                  child: Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(10, 20, 10, 20),
                                                    child:  Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          AppLocalizations().lbAva,
                                                          style: TextStyle(
                                                              color: Colors.praimarydark,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15),
                                                        ),
                                                        new Spacer(),
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(
                                                              0, 3, 0, 0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down,
                                                            color: Colors.praimarydark,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),),



                                              widget.isStore=='1'?Visibility(visible: true,child: snapshot
                                                  .data
                                                  .results
                                                  .storeList.listStoreDrug.length==0?
                                              Padding(
                                                padding:
                                                EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10),
                                                child: Text(
                                                    AppLocalizations().lbNotAvaD),
                                              ):
                                              Container(
                                                child: Wrap(
                                                  children: <Widget>[
                                                    ListView.builder(
                                                        shrinkWrap:
                                                        true,
                                                        physics:
                                                        NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                        snapshot
                                                            .data
                                                            .results
                                                            .storeList.listStoreDrug
                                                            .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                        ctxt,
                                                            int index) {
                                                          return new Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                0),
                                                            child:
                                                            GestureDetector(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      image:
                                                                      AssetImage('assets/images/storecard.png'),
                                                                      fit:
                                                                      BoxFit.fill,
                                                                    )),
                                                                child:
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      10,
                                                                      5,
                                                                      10,
                                                                      0),
                                                                  child:
                                                                  Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  snapshot
                                                                                      .data
                                                                                      .results
                                                                                      .storeList.listStoreDrug[index].nameStore.toString(),
                                                                                  style: TextStyle(
                                                                                    color: Colors.grey,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            new Spacer(),

                                                                          ],
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap:
                                                                  () {
                                                                Navigator.of(context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) => storeDetails(  snapshot
                                                                        .data
                                                                        .results
                                                                        .storeList.listStoreDrug[index].nameStore,   snapshot
                                                                        .data
                                                                        .results
                                                                        .storeList.listStoreDrug[index].id),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                  ],
                                                ),
                                              )):

                                              Visibility(visible: false,child: snapshot
                                                  .data
                                                  .results
                                                  .storeList.listStoreDrug.length==0?
                                              Padding(
                                                padding:
                                                EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10),
                                                child: Text(
                                                    AppLocalizations().lbNotAvaD),
                                              ):
                                              Container(
                                                child: Wrap(
                                                  children: <Widget>[
                                                    ListView.builder(
                                                        shrinkWrap:
                                                        true,
                                                        physics:
                                                        NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                        snapshot
                                                            .data
                                                            .results
                                                            .storeList.listStoreDrug
                                                            .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                        ctxt,
                                                            int index) {
                                                          return new Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                0),
                                                            child:
                                                            GestureDetector(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      image:
                                                                      AssetImage('assets/images/storecard.png'),
                                                                      fit:
                                                                      BoxFit.fill,
                                                                    )),
                                                                child:
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      10,
                                                                      5,
                                                                      10,
                                                                      0),
                                                                  child:
                                                                  Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  snapshot
                                                                                      .data
                                                                                      .results
                                                                                      .storeList.listStoreDrug[index].nameStore.toString(),
                                                                                  style: TextStyle(
                                                                                    color: Colors.grey,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            new Spacer(),

                                                                          ],
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap:
                                                                  () {
                                                                Navigator.of(context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) => storeDetails(  snapshot
                                                                        .data
                                                                        .results
                                                                        .storeList.listStoreDrug[index].nameStore,   snapshot
                                                                        .data
                                                                        .results
                                                                        .storeList.listStoreDrug[index].id),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                  ],
                                                ),
                                              )),







                                            ],
                                          ),
                                        )



                                ,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )],);
                        } else if (snapshot.hasError) {
                          return Text('error');
                        } else {
                          return Container(height:MediaQuery.of(context).size.height,child: Center(
                            child: CircularProgressIndicator(valueColor:
                            new AlwaysStoppedAnimation<Color>(
                                Colors.praimarydark)),),);
                        }
                      },
                    ),
                  );
              }
            }
            return Center(
              child: CircularProgressIndicator(valueColor:
              new AlwaysStoppedAnimation<Color>(
                  Colors.praimarydark)),
            );
          })




     ,
    );
  }


  Widget showDialogwindowDone(String drugN) {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Stack(children: <Widget>[SingleChildScrollView(
        child: Container(
decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'))),
          child: Form(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      drugN,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: TextFormField(
                    controller: _ownerD,
                    decoration: InputDecoration(
                      filled: true,
                      hintText:AppLocalizations().lbOwner,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ), //can also add icon to the end of the textfiled
                      //  suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                  ),
                ),

                Visibility(
                  child: Form(
                    key: fromdate,
                    child:  DateTimeField(
                      validator: (val) {
                        if (val != null) {
                          return null;
                        } else {
                          return AppLocalizations().lbRemi;
                        }
                      },
                      onSaved: (value) {
                        fromTime = value.toString().substring(11,19);
                      },
                      format: format,
                      decoration: new InputDecoration(
                          hintText: AppLocalizations().lbRemi),
                      style: TextStyle(
                          color: Colors.praimarydark),
                      onShowPicker: (context,
                          currentValue) async {
                        final time =
                        await showTimePicker(
                          context: context,
                          initialTime:
                          TimeOfDay.fromDateTime(
                              currentValue ??
                                  DateTime.now()),
                        );
                        return DateTimeField.convert(
                            time);
                      },
                    ),
                  ),
                  visible: true,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {
                        if (fromdate.currentState.validate()) {
                          // fromdate.currentState.save();
                          fromdate.currentState.save();
                        }
                        gg.add(Alarm(
                            drugN: drugN,
                            ownerD: _ownerD.text,
                            time: fromTime));

                        _save(gg,drugN);

                        Navigator.of(context).pop();




                        //    _buildSubmitFormCo(context, wareId, offerId, dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.praimarydark,
                      child: Center(
                        child: new Text(
                          AppLocalizations().lbDone,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      )],),
    );
  }

  _save(List<Alarm> myListOfStringss,String DrugN
      ) async {
    print(myListOfStringss);

    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    alarmL = preferences.getString('alamL');


    if(alarmL!=null){
      alarmLi = (json.decode(alarmL) as List<dynamic>)
          .map<Alarm>((item) => Alarm.fromJson(item))
          .toList();

      String fgfh = json.encode(
        gg.map<Map<String, dynamic>>((music) => Alarm.toMap(music)).toList(),
      );
      List<Alarm> newlisst = (json.decode(fgfh) as List<dynamic>)
          .map<Alarm>((item) => Alarm.fromJson(item))
          .toList();
      List list1 = alarmLi;
      List list2 = newlisst;
      list1.addAll(list2);
      String last = json.encode(
        list1.map<Map<String, dynamic>>((music) => Alarm.toMap(music)).toList(),
      );
      print(last);
      sharedPrefs.setString('alamL', last);





    }else{

      String fgfh = json.encode(
        gg.map<Map<String, dynamic>>((music) => Alarm.toMap(music)).toList(),
      );


      sharedPrefs.setString('alamL', fgfh);


    }
    _showDailyAtTime(DrugN);


  }


  Future<void> _showDailyAtTime(String Drugn) async {
    String hour = fromTime.substring(0,2);
    String minu = fromTime.substring(3,5);
    String sec = fromTime.substring(6,8);

    var time = Time(int.parse(hour),int.parse(minu),int.parse(sec));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description',
      importance: Importance.Max,
      priority: Priority.High,   styleInformation: DefaultStyleInformation(true, true),);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Alarm at ${time.hour}:${time.minute}.${time.second}',
      'for this drugs' + Drugn, //null
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',);





  }


}
