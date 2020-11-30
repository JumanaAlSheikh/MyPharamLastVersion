import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Bloc/blocPharma.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Model/pharmaListModel.dart';
import 'package:pharmas/Repository/pharmaRepository.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/pharmaResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/Pharma/pharmaDetailsPage.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class pharmaListP extends StatefulWidget {
  @override
  _pharmaListP createState() => new _pharmaListP();
}

class _pharmaListP extends State<pharmaListP> {
  ScrollController _sc = new ScrollController();
  List<City> citylist;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPh =
      new GlobalKey<RefreshIndicatorState>();
  List<pharmasAllList> pharmasList;
  String idcityPh;
  TextEditingController editingController = TextEditingController();
  String cityname;
  String sessionId;
  PharmaResponse response;
  int g= 1;

  var preferences;
  bool isLoading = false;
  bool activeSearch = false;
  List<pharmasAllList> tListall;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var items = List<pharmasAllList>();
  List<pharmasAllList> tList;
  String nameSearchPharma;
  String seawa, searchePh, citynum;
  static int page = 2;
  FocusNode focusNode;
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
  void filterSearchResults(String query) {
    activeSearch = true;

    List<pharmasAllList> dummySearchList = List<pharmasAllList>();
    dummySearchList.addAll(tListall);
    if (query.isNotEmpty || query != "") {
      List<pharmasAllList> dummyListData = List<pharmasAllList>();
      dummySearchList.forEach((item) {
        g=query.length;

        if (item.PharmacyName.toLowerCase().trimLeft().substring(0,g).contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });

      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(tListall);
      });
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
    focusNode = FocusNode();

    activeSearch = false;

    getValueString();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });

    //  navigationPage();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),
        ),
      ),
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
          final PharmaRepository _repository = PharmaRepository();

          response = await _repository.gerPharmaList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0;
                i <= response.results.pharmas.listpharma.length;
                i++) {
              tList = new List.from(response.results.pharmas.listpharma);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = pharmasList + tList;
              } else {
                tListall = tListall + tList;
              }

              page++;
            });
          } else {
            Toast.show(response.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        } else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter": idcityPh,
            "Search": searchePh,
          };
          final PharmaRepository _repository = PharmaRepository();

          response = await _repository.gerPharmaList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0;
                i <= response.results.pharmas.listpharma.length;
                i++) {
              tList = new List.from(response.results.pharmas.listpharma);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = pharmasList + tList;
              } else {
                tListall = tListall + tList;
              }

              page++;
            });
          } else {
            Toast.show(response.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        }
      } else {
        if (nameSearchPharma == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter": -1,
            "Search": "",
          };
          final PharmaRepository _repository = PharmaRepository();

          response = await _repository.gerPharmaList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0;
                i <= response.results.pharmas.listpharma.length;
                i++) {
              tList = new List.from(response.results.pharmas.listpharma);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = pharmasList + tList;
              } else {
                tListall = tListall + tList;
              }
              print(tListall.length.toString());
              page++;
            });
          } else {
            Toast.show(response.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        } else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": page,
            "Filter": idcityPh,
            "Search": "",
          };
          final PharmaRepository _repository = PharmaRepository();

          response = await _repository.gerPharmaList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (response.code == '1') {
            for (int i = 0;
                i <= response.results.pharmas.listpharma.length;
                i++) {
              tList = new List.from(response.results.pharmas.listpharma);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoading = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListall == null) {
                tListall = pharmasList + tList;
              } else {
                tListall = tListall + tList;
              }

              page++;
            });
          } else {
            Toast.show(response.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        }
      }
    }
  }

  getValueString() async {
    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    citynum = preferences.getString('cityn');
    cityname = preferences.getString('cityname');
    blocCity.getCity(langSave);

    if (idcityPh == null) {
      if (citynum == null) {
        idcityPh = '-1';
      } else {
        idcityPh = null;
      }
    }
    if (citynum == null) {
      if (idcityPh == null) {
        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": -1,
          "Search": "",
        };
        // blocOffer.getOfferList(sessionId, data);
        print(data);

        final PharmaRepository _repository = PharmaRepository();

        response = await _repository.gerPharmaList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.pharmas.listpharma;
          items.addAll(tListall);
        });
      } else {
        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": idcityPh,
          "Search": "",
        };
        print(data);
        final PharmaRepository _repository = PharmaRepository();

        response = await _repository.gerPharmaList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.pharmas.listpharma;
          items.addAll(tListall);
        });
      }
    } else {
      if (idcityPh == null) {
        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": citynum,
          "Search": "",
        };
        // blocOffer.getOfferList(sessionId, data);
        print(data);

        final PharmaRepository _repository = PharmaRepository();

        response = await _repository.gerPharmaList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.pharmas.listpharma;
          items.addAll(tListall);
        });
      } else {
        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": idcityPh,
          "Search": "",
        };
        print(data);
        final PharmaRepository _repository = PharmaRepository();

        response = await _repository.gerPharmaList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.pharmas.listpharma;
          items.addAll(tListall);
        });
      }
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
            hintText: AppLocalizations().lbEnterPhN,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                activeSearch = false;
                editingController.clear();
                items.clear();
                items.addAll(tListall);
              });
            },
          )
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
        title: Text(AppLocalizations().lbPharma),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {setState(() => activeSearch = true);    focusNode.requestFocus();},
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
    // TODO: implement build
    return new Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: false,
        appBar: _appBar(),
        body: RefreshIndicator(
          key: _refreshIndicatorKeyPh,
          onRefresh: _refresh,
          child: StreamBuilder(
            stream: blocCity.subject.stream,
            builder:
                (BuildContext context, AsyncSnapshot<CityResponse> snapshot) {
              if (snapshot.hasData) {
                /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

                citylist = snapshot.data.results.citiesr.cities;

                return new Container(
                    child: tListall == null
                        ? Center(
                            child:CircularProgressIndicator(
                                valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.praimarydark)))
                        : Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                  child: Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Row(
                                          children: <Widget>[
                                            nameSearchPharma == null
                                                ? citynum == null
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 15, 0, 5),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                                AppLocalizations().lbFilA)
                                                          ],
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 15, 0, 5),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                                 AppLocalizations().lbFil +
                                                                    cityname)
                                                          ],
                                                        ),
                                                      )
                                                : Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 5, 5, 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                            AppLocalizations().lbFil+' $nameSearchPharma')
                                                      ],
                                                    ),
                                                  )
                                          ],
                                        ),
                                        onTap: () {
                                          displayBottomSheetPh(
                                              context, citylist);

                                        },
                                      )
                                    ],
                                  ),
                                ),
                                activeSearch == true
                                    ? items.length != 0?
                                Expanded(child: ListView.builder(
                                  itemCount: items.length + 1,
                                  // Add one more item for progress indicator
                                  padding:
                                  EdgeInsets.symmetric(vertical: 8.0),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == items.length) {
                                      return _buildProgressIndicator();
                                    } else {
                                      return new Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: GestureDetector(
                                          child: Container(
                                            child: Padding(
                                              padding:
                                              EdgeInsets.fromLTRB(
                                                  45, 5, 10, 5),
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        10, 0, 10, 0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          items[index]
                                                              .PharmacyName
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .praimarydark,
                                                              fontSize:
                                                              17,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(10, 0,
                                                        10, 10),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          items[index]
                                                              .City
                                                              .toString(),
                                                          style:
                                                          TextStyle(
                                                            color: Colors
                                                                .grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets
                                                          .fromLTRB(0, 2,
                                                          0, 5),
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets
                                                            .fromLTRB(
                                                            10,
                                                            0,
                                                            10,
                                                            0),
                                                        child: Row(
                                                          children: <
                                                              Widget>[
                                                            Text(
                                                              items[index]
                                                                  .Address
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                  items[index].Phone=="null"?
                                                  Visibility(child:  GestureDetector(onTap: (){
//                                                          _initiateCallPhone(  items[index].Phone);

                                                  },child:    Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.phone,color: Colors.praimarydark,),

                                                        Padding(
                                                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                            child: Text(   'items[index].Phone',style: TextStyle(color: Colors.grey))
                                                        )
                                                      ],
                                                    ),
                                                  ),),visible: false,):
                                                  Visibility(child: GestureDetector(onTap: (){
                                                    //    _initiateCallPhone(  items[index].Phone);

                                                  },child:    Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.phone,color: Colors.praimarydark,),

                                                        Padding(
                                                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                            child: Text(   items[index].Phone,style: TextStyle(color: Colors.grey))
                                                        )
                                                      ],
                                                    ),
                                                  ),),visible: true,),
                                                  items[index].Mobile=="null"?Visibility(
                                                    child: GestureDetector(onTap: (){
                                                      //    _initiateCallMobile( widget.pharmaItem.Mobile);

                                                    },child:  Padding(
                                                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(Icons.phone_android,color: Colors.praimarydark,),

                                                          Padding(
                                                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                              child: Text(' items[index].Mobile',style: TextStyle(color: Colors.grey))
                                                          )
                                                        ],
                                                      ),
                                                    ),),visible: false,):
                                                  Visibility(
                                                    child: GestureDetector(onTap: (){
                                                      //  _initiateCallMobile( widget.pharmaItem.Mobile);

                                                    },child:  Padding(
                                                      padding: EdgeInsets.fromLTRB(10, 5, 10, 25),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(Icons.phone_android,color: Colors.praimarydark,),

                                                          Padding(
                                                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                              child: Text(  items[index].Mobile,style: TextStyle(color: Colors.grey))
                                                          )
                                                        ],
                                                      ),
                                                    ),),visible: true,)
                                                ],
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/pharmacard.png'),
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (_, __, ___) =>
                                                        Directionality(
                                                          textDirection:
                                                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                          child:  pharmaDeails(
                                                        items[index])),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                      ;
                                    }
                                  },
                                  controller: _sc,
                                ),):
                                Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(
                                      0, 10, 0, 10),
                                  child: Text(
                                      AppLocalizations().lbNOData),
                                )
                                    : tListall == null
                                        ? Container()
                                        :Expanded(child: ListView.builder(
                                  itemCount: tListall.length + 1,
                                  // Add one more item for progress indicator
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  itemBuilder: ( context,
                                       index) {
                                    if (index == tListall.length) {
                                      return _buildProgressIndicator();
                                    } else {
                                      return new Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: GestureDetector(
                                          child: Container(
                                            child: Padding(
                                              padding:
                                              EdgeInsets.fromLTRB(
                                                  45, 5, 10, 5),
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        10,
                                                        0,
                                                        10,
                                                        0),
                                                    child: Row(
                                                      children: <
                                                          Widget>[
                                                        Text(
                                                          tListall[
                                                          index]
                                                              .PharmacyName
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .praimarydark,
                                                              fontSize:
                                                              17,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        10,
                                                        0,
                                                        10,
                                                        10),
                                                    child: Row(
                                                      children: <
                                                          Widget>[
                                                        Text(
                                                          tListall[
                                                          index]
                                                              .City
                                                              .toString(),
                                                          style:
                                                          TextStyle(
                                                            color: Colors
                                                                .grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                      EdgeInsets
                                                          .fromLTRB(
                                                          0,
                                                          2,
                                                          0,
                                                          5),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .fromLTRB(
                                                            10,
                                                            0,
                                                            10,
                                                            0),
                                                        child: Row(
                                                          children: <
                                                              Widget>[
                                                            Text(
                                                              tListall[index]
                                                                  .Address
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                  tListall[index].Phone=="null"?
                                                  Visibility(child:  GestureDetector(onTap: (){
//                                                          _initiateCallPhone(  items[index].Phone);

                                                  },child:    Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.phone,color: Colors.praimarydark,),

                                                        Padding(
                                                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                            child: Text(   'items[index].Phone',style: TextStyle(color: Colors.grey))
                                                        )
                                                      ],
                                                    ),
                                                  ),),visible: false,):
                                                  Visibility(child: GestureDetector(onTap: (){
                                                    //    _initiateCallPhone(  items[index].Phone);

                                                  },child:    Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.phone,color: Colors.praimarydark,),

                                                        Padding(
                                                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                            child: Text(   tListall[index].Phone,style: TextStyle(color: Colors.grey))
                                                        )
                                                      ],
                                                    ),
                                                  ),),visible: true,),
                                                  tListall[index].Mobile=="null"?Visibility(
                                                    child: GestureDetector(onTap: (){
                                                      //    _initiateCallMobile( widget.pharmaItem.Mobile);

                                                    },child:  Padding(
                                                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(Icons.phone_android,color: Colors.praimarydark,),

                                                          Padding(
                                                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                              child: Text( 'items[index].Mobile',style: TextStyle(color: Colors.grey))
                                                          )
                                                        ],
                                                      ),
                                                    ),),visible: false,):
                                                  Visibility(
                                                    child: GestureDetector(onTap: (){
                                                      //  _initiateCallMobile( widget.pharmaItem.Mobile);

                                                    },child:  Padding(
                                                      padding: EdgeInsets.fromLTRB(10, 5, 10, 25),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(Icons.phone_android,color: Colors.praimarydark,),

                                                          Padding(
                                                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                              child: Text(  tListall[index].Mobile,style: TextStyle(color: Colors.grey))
                                                          )
                                                        ],
                                                      ),
                                                    ),),visible: true,)
                                                ],
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                                image:
                                                DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/pharmacard.png'),
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(
                                              PageRouteBuilder(
                                                pageBuilder: (_, __,
                                                    ___) =>
                                                    Directionality(
                                                      textDirection:
                                                      langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                      child:  pharmaDeails(
                                                        tListall[
                                                        index])),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                      ;
                                    }
                                  },
                                  controller: _sc,
                                ),) ,
                              ],
                            ),
                          ));
              } else if (snapshot.hasError) {
                return Text('error');
              } else {
                return Center(
                  child: activeSearch==true?
                  Text(AppLocalizations().lbNOData):
                  CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.praimarydark)),
                );
              }
            },
          ),
        ));
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
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        )),
                    onTap: () {
                      setState(() {
                        items.clear();
                        citiee[index].check = true;
                        nameSearchPharma = citiee[index].cityName;
                        idcityPh = citiee[index].id.toString();
                        getValueString();
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }),
          );
        });
  }
}
