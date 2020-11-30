import 'dart:async';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';

import 'package:pharmas/Bloc/blocDurgs.dart';

import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Model/durgsModel.dart';
import 'package:pharmas/Repository/durgsrepository.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/durgsResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/Durgs/durgDetails.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
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
class durgsList extends StatefulWidget {
  @override
  _durgsList createState() => new _durgsList();
}

class _durgsList extends State<durgsList> {
  List<durgsAllList> durgsList;
  FocusNode focusNode;

  TextEditingController editingController = TextEditingController();
  bool activeSearch = false;
  String  searchePh;
  int g= 1;

  String nameSearchPharma;
  int idcityPh;
  var items = List<durgsAllList>();
  List<durgsAllList> tListall;
  DurgsResponse response;
  ScrollController _sc = new ScrollController();
  static int page = 2;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
  BehaviorSubject<ReceivedNotification>();
  static int pageSearch = 1;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();

  NotificationAppLaunchDetails notificationAppLaunchDetails;
  List<durgsAllList> tList;
  bool isLoading = false;

  List<City> citylist;
  final _ownerD = new TextEditingController();
  String fromTime;
  int load=0;
  var fromdate = GlobalKey<FormState>();
  intl.DateFormat  format ;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPh =
  new GlobalKey<RefreshIndicatorState>();
  final MethodChannel platform =
  MethodChannel('crossingthestreams.io/resourceResolver');
  String sessionId;
  var preferences;

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
    langSave = preferences.getString('lang');

    blocDurgs.getCategoryList('en');

    setState(() {
  load=0;

    if(tListall!=null){
      tListall.clear();
    }if(items!=null){
    items.clear();

  }
});
if(searchePh==null){
  if (idcityPh == null) {
    Map<String, dynamic> data = {
      "PageSize": 10,
      "PageNumber": 1,
      "Filter": -1,
      "Search": "",
    };

    //blocDurgs.getDurgsList(sessionId, data);
    // blocOffer.getOfferList(sessionId, data);

    final DurgsRepository _repository = DurgsRepository();

    response = await _repository.getDurgsLisy(sessionId, data,langSave);
    setState(() {
      if(tListall!=null){
        tListall.clear();
      }if(items!=null){
        items.clear();

      }
      tListall = response.results.durgs.listdurgs;
      items.addAll(tListall);
    });
  }
  else {
    Map<String, dynamic> data = {
      "PageSize": 10,
      "PageNumber": 1,
      "Filter": idcityPh,
      "Search": "",
    };
    final DurgsRepository _repository = DurgsRepository();

    response = await _repository.getDurgsLisy(sessionId, data,langSave);
    setState(() {
      if(tListall!=null){
        tListall.clear();
      }if(items!=null){
        items.clear();

      }
      tListall = response.results.durgs.listdurgs;
      items.addAll(tListall);
    });
  }
}else{
  if (idcityPh == null) {
    Map<String, dynamic> data = {
      "PageSize": 10,
      "PageNumber": 1,
      "Filter": -1,
      "Search": searchePh,
    };

    //blocDurgs.getDurgsList(sessionId, data);
    // blocOffer.getOfferList(sessionId, data);

    final DurgsRepository _repository = DurgsRepository();

    response = await _repository.getDurgsLisy(sessionId, data,langSave);
    setState(() {
      if(tListall!=null){
        tListall.clear();
      }if(items!=null){
        items.clear();

      }
      tListall = response.results.durgs.listdurgs;
      items.addAll(tListall);
    });
  }
  else {
    Map<String, dynamic> data = {
      "PageSize": 10,
      "PageNumber": 1,
      "Filter": idcityPh,
      "Search": searchePh,
    };
    final DurgsRepository _repository = DurgsRepository();

    response = await _repository.getDurgsLisy(sessionId, data,langSave);
    setState(() {
      if(tListall!=null){
        tListall.clear();
      }if(items!=null){
        items.clear();

      }
      tListall = response.results.durgs.listdurgs;
      items.addAll(tListall);
    });
  }
}

  }



  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(AppLocalizations().lbOk),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();

              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {

    });
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
  format  =intl.DateFormat("HH:mm");
    navigationPage();

    focusNode = FocusNode();

    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    activeSearch = false;
    if(idcityPh!=null) {
      idcityPh = idcityPh;
    }
    getValueString();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });

    //  navigationPage();
  }

  void filterSearchResults(String query) {
    activeSearch = true;

    List<durgsAllList> dummySearchList = List<durgsAllList>();
    dummySearchList.addAll(tListall);
    if (query.isNotEmpty) {
      List<durgsAllList> dummyListData = List<durgsAllList>();

      dummySearchList.forEach((item) async {
        g=query.length;

        if (
            item.CommerceName.toLowerCase().trimLeft().substring(0,g).contains(query.toLowerCase())) {
          dummyListData.add(item);
        }else{
          searchePh=query;
        //  _getMoreData(page);
setState(() {
  load=1;
});
         // _buildProgressIndicator();

          if (idcityPh == null) {

            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageSearch,
              "Filter": -1,
              "Search": searchePh,
            };

            //blocDurgs.getDurgsList(sessionId, data);
            // blocOffer.getOfferList(sessionId, data);

            final DurgsRepository _repository = DurgsRepository();

            response = await _repository.getDurgsLisy(sessionId, data,langSave);
            setState(() {
              load=0;

              tListall = response.results.durgs.listdurgs;
              items.addAll(tListall);
            });
            if(tListall.length==0){
              pageSearch++;
            }
          }
          else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageSearch,
              "Filter": idcityPh,
              "Search": searchePh,
            };
            final DurgsRepository _repository = DurgsRepository();

            response = await _repository.getDurgsLisy(sessionId, data,langSave);
            setState(() {
              tListall = response.results.durgs.listdurgs;
              items.addAll(tListall);
            });
            if(tListall.length==0){
              pageSearch++;
            }
          }


        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    }
    else {
      setState(() {
        searchePh=null;

        activeSearch=false;
        tListall.clear();
        items.clear();
      //  getValueString();
        initState();
      });
    }
  }


  PreferredSizeWidget _appBar() {

    if (activeSearch) {
      return AppBar(
        leading: Icon(Icons.search),
        title: TextField(
          focusNode: focusNode,

          onChanged: (value) {
            filterSearchResults(value);
            searchePh = value;
          },
          controller: editingController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white)),
            labelStyle: new TextStyle(color: Colors.white),
            hintText: AppLocalizations().lbEnDrugN,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                searchePh=null;
                activeSearch = false;
                editingController.clear();
                items.clear();
                items.addAll(tListall);
              });
              initState();
    }),

        ],
      );
    } else {
      return AppBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: searchePh==null?Text(AppLocalizations().lbDrug): searchePh==''?Text(AppLocalizations().lbDrug):Text(searchePh),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {setState(() => activeSearch = true);  focusNode.requestFocus();},
          ),
        ],
      );
    }
  }
  Future<void> _refresh() async {
    // dummy code

    getValueString();
    return Future.value();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _appBar(),
      body: RefreshIndicator(
        key: _refreshIndicatorKeyPh,
        onRefresh: _refresh,
        child:    StreamBuilder(
          stream: blocDurgs.subjectCat.stream,
          builder:
              (BuildContext context, AsyncSnapshot<CityResponse> snapshot) {
            if (snapshot.hasData) {
              /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

              citylist = snapshot.data.results.citiesr.cities;
              print(load.toString());
              return new Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: load==0?Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            child: Row(
                              children: <Widget>[
                                nameSearchPharma == null
                                    ? Padding(
                                  padding:
                                  EdgeInsets
                                      .fromLTRB(
                                      0,
                                      15,
                                      0,
                                      5),
                                  child: Row(
                                    children: <
                                        Widget>[
                                      Text(
                                          AppLocalizations().lbFilAC)
                                    ],
                                  ),
                                )
                                    : Padding(
                                  padding:
                                  EdgeInsets
                                      .fromLTRB(
                                      5,
                                      5,
                                      5,
                                      5),
                                  child: Row(
                                    children: <
                                        Widget>[
                                      Text(
                                          AppLocalizations().lbFilC+' $nameSearchPharma')
                                    ],
                                  ),
                                )
                              ],
                            ),
                            onTap: () {
                              displayBottomSheetPh(
                                  context, citylist);

/*
                          Navigator.of(
                              context)
                              .push(
                            PageRouteBuilder(
                              pageBuilder: (_,
                                  __,
                                  ___) =>
                                  IntroPage(
                                      ),
                            ),
                          );*/
                            },
                          )
                        ],

                      ),
                    ),
                    activeSearch == true
                        ? Expanded(
                        child: ListView.builder(
                          itemCount: items.length + 1,
                          // Add one more item for progress indicator
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == items.length) {
                              return _buildProgressIndicator();
                            } else {
                              return new
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: GestureDetector(child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 5),child: Row(
                                          children: <Widget>[
                                            Container(width: 250,child: Text(
                                              items[index]
                                                  .CommerceName
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.praimarydark,fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),),new Spacer(),
                                          ],),),
                                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(
                                          children: <Widget>[ Text(
                                            items[index]
                                                .Strengths
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),],),),

                                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(
                                          children: <Widget>[ Text(
                                            items[index]
                                                .form
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),],),),

                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 5, 0, 3),
                                            child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                              Text(
                                                items[index]
                                                    .Manufacture
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.red,fontWeight: FontWeight.bold),
                                              ),
                                            ],),)
                                        ),
                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 3),
                                            child:Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child:
                                            Row(children: <Widget>[ Container(width: 250,child: Text(
                                              items[index]
                                                  .ScientificName
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,

                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),),],),)
                                        ),
                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 3),
                                            child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                              Text(
                                                items[index]
                                                    .Category
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],),)
                                        ),

                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/carddurg.png'),
                                        fit: BoxFit.fill,
                                      )),
                                ),onTap: (){
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          Directionality(
                                            textDirection:
                                            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                            child:durgDetails(  items[index].CommerceName,  items[index].id,'1')),
                                    ),
                                  );
                                },),
                              );
                            }
                          },
                          controller: _sc,
                        ))
                        : tListall == null
                        ? Container()
                        : Expanded(
                        child: ListView.builder(
                          itemCount: tListall.length + 1,
                          // Add one more item for progress indicator
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == tListall.length) {
                              return _buildProgressIndicator();
                            } else {
                              return new
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: GestureDetector(child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 5),child: Row(
                                          children: <Widget>[ Container(width: 250,child: Text(
                                            tListall[index]
                                                .CommerceName
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,

                                            style: TextStyle(
                                                color: Colors.praimarydark,fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),),],),),
                                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(
                                          children: <Widget>[ Text(
                                            tListall[index]
                                                .Strengths
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),],),),

                                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(
                                          children: <Widget>[ Text(
                                            tListall[index]
                                                .form
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),],),),

                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 5, 0, 3),
                                            child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                              Text(
                                                  tListall[index]
                                                      .Manufacture
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.red,fontWeight: FontWeight.bold)
                                              ),
                                            ],),)
                                        ),

                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 3),
                                            child:Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child:
                                            Row(children: <Widget>[
                                              Container(width: 250,child:   Text(
                                                tListall[index]
                                                    .ScientificName
                                                    .toString(),
                                                overflow: TextOverflow.ellipsis,

                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),),],),)
                                        ),
                                        Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 3),
                                            child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                              Text(
                                                tListall[index]
                                                    .Category
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],),)
                                        ),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/carddurg.png'),
                                        fit: BoxFit.fill,
                                      )),
                                ),onTap: (){
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          Directionality(
                                            textDirection:
                                            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                            child:durgDetails(  tListall[index].CommerceName,  tListall[index].id,'1')),
                                    ),
                                  );
                                },),
                              );
                            }
                          },
                          controller: _sc,
                        )),
                  ],
                ):Container(height: MediaQuery.of(context).size.height,width:
                MediaQuery.of(context).size.width,child: Center(
                  child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.praimarydark)),
                ),),
              );
            } else if (snapshot.hasError) {
              return Text('error');
            } else {
              return Container(height: MediaQuery.of(context).size.height,child: Center(
                child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Colors.praimarydark)),
              ),);
            }
          },
        ),
      )







    ,
    );
  }
  _getMoreData(int index) async {
    tList = new List();
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      if (activeSearch == true) {
        if (nameSearchPharma == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter": -1,
            "Search": searchePh,
          };

          //blocDurgs.getDurgsList(sessionId, data);
          // blocOffer.getOfferList(sessionId, data);

          final DurgsRepository _repository = DurgsRepository();

          response = await _repository.getDurgsLisy(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0; i <= response.results.durgs.listdurgs.length; i++) {
              tList = new List.from(response.results.durgs.listdurgs);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = durgsList + tList;
              } else {
                tListall = tListall + tList;
              }

              page++;
            });
          }else{ Toast.show(
              response.msg.toString(),
              context,
              duration: 4,
              gravity: Toast.BOTTOM);}
        }
        else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter":idcityPh,
            "Search": searchePh,
          };
          final DurgsRepository _repository = DurgsRepository();

          response = await _repository.getDurgsLisy(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0; i <= response.results.durgs.listdurgs.length; i++) {
              tList = new List.from(response.results.durgs.listdurgs);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = durgsList + tList;
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
      }else{

        if (nameSearchPharma == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter": -1,
            "Search": "",
          };

          //blocDurgs.getDurgsList(sessionId, data);
          // blocOffer.getOfferList(sessionId, data);

          final DurgsRepository _repository = DurgsRepository();

          response = await _repository.getDurgsLisy(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0; i <= response.results.durgs.listdurgs.length; i++) {
              tList = new List.from(response.results.durgs.listdurgs);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = durgsList + tList;
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
        } else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter": idcityPh,
            "Search": "",
          };
          final DurgsRepository _repository = DurgsRepository();

          response = await _repository.getDurgsLisy(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0; i <= response.results.durgs.listdurgs.length; i++) {
              tList = new List.from(response.results.durgs.listdurgs);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = durgsList + tList;
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

    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(valueColor:
          new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),
        ),
      ),
    );
  }

  Future<void> _showDailyAtTime(String Drugn) async {
    String hour = fromTime.substring(11,13);
    String minu = fromTime.substring(14,16);
    String sec = fromTime.substring(17,19);

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


  void displayBottomSheetPh(BuildContext context, List<City> citiee) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/filter.jpg'),
                  fit: BoxFit.fill,
                )),
            child: ListView.builder(
                itemCount: citiee.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return new GestureDetector(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(citiee[index].cityName),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Divider(
                                  height: 1,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        )),
                    onTap: () {
                      setState(() {
                        citiee[index].check = true;
                        nameSearchPharma = citiee[index].cityName;
                        idcityPh = citiee[index].id;
                        load=1;

if(tListall!=null){
  tListall.clear();
}
                        if(items!=null){
                          items.clear();
                        }
                     //  getValueString();
                        initState();
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }),
          );
        });
  }

}
