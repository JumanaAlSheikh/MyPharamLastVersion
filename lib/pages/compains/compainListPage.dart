import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmas/Model/compainListModel.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/ScrollingText.dart';
import 'package:pharmas/Response/CompainResponse.dart';
import 'package:pharmas/Repository/CompainRepository.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/compains/compainDetails.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class compainListPage extends StatefulWidget {
  @override
  _compainListPage createState() => new _compainListPage();
}

class _compainListPage extends State<compainListPage> {
  static List<compainAllList> compainList;
  static int page = 2;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String seawa, searchePh , citynum,cityname;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPh =
      new GlobalKey<RefreshIndicatorState>();
  List<compainAllList> tList;
  List<compainAllList> tListall;

  TextEditingController editingController = TextEditingController();
  String nameSearchPharma;
  String idcityPh;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  String sessionId;
  var preferences;
  FocusNode focusNode;

  bool activeSearch = false;
  List<City> citylist;
  int g= 1;

  CompainResponse response;
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  var items = List<compainAllList>();
  int totalcount;
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

    List<compainAllList> dummySearchList = List<compainAllList>();
    dummySearchList.addAll(tListall);
    if (query.isNotEmpty) {
      List<compainAllList> dummyListData = List<compainAllList>();
      dummySearchList.forEach((item) {
        g=query.length;

        if (item.compainName.toLowerCase().trimLeft().substring(0,g).contains(query.toLowerCase())) {
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

  getValueString() async {
    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    citynum=preferences.getString('cityn');
    cityname=preferences.getString('cityname');
    blocCity.getCity(langSave);

    if(idcityPh==null ){
      if(citynum==null){
        idcityPh='-1';
      }else{
        idcityPh=null;

      }
    }

    if(citynum==null) {
      if (idcityPh == null) {
        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": -1,
          "Search": "",
        };
        //  blocOffer.getOfferList(sessionId, data);

        final CompainRepository _repository = CompainRepository();

        response = await _repository.getcompainList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.compains.listcompain;
          totalcount = response.totalCount;
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
        final CompainRepository _repository = CompainRepository();

        response = await _repository.getcompainList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.compains.listcompain;
          totalcount = response.totalCount;

          items.addAll(tListall);
        });
      }
    }else{
      if (idcityPh == null) {
        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": citynum,
          "Search": "",
        };
        //  blocOffer.getOfferList(sessionId, data);

        final CompainRepository _repository = CompainRepository();

        response = await _repository.getcompainList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.compains.listcompain;
          totalcount = response.totalCount;
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
        final CompainRepository _repository = CompainRepository();

        response = await _repository.getcompainList(sessionId, data,langSave);
        setState(() {
          tListall = response.results.compains.listcompain;
          totalcount = response.totalCount;

          items.addAll(tListall);
        });
      }
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
print(langSave);
    focusNode = FocusNode();

    activeSearch = false;
    //  _getMoreData(page);
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });
    //  navigationPage();
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
            hintText: AppLocalizations().lbEnComN,
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
        title: Text(AppLocalizations().lbCom),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {setState(() => activeSearch = true);
    focusNode.requestFocus();},
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
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return new Scaffold(
        appBar: _appBar(),
        //   resizeToAvoidBottomPadding: true,
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
                                      ? citynum==null?Padding(
                                    padding:
                                    EdgeInsets.fromLTRB(0, 15, 0, 5),
                                    child: Row(
                                      children: <Widget>[
                                        Text(AppLocalizations().lbFilA)
                                      ],
                                    ),
                                  ):
                                  Padding(
                                    padding:
                                    EdgeInsets.fromLTRB(0, 15, 0, 5),
                                    child: Row(
                                      children: <Widget>[
                                        Text(AppLocalizations().lbFil + cityname)
                                      ],
                                    ),
                                  )
                                      : Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                                displayBottomSheetPh(context, citylist);

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
                              child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                              child: GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  controller: _sc,
                                  childAspectRatio: (itemWidth / itemHeight),
                                  padding: const EdgeInsets.all(4.0),
                                  mainAxisSpacing: 4.0,
                                  crossAxisSpacing: 6.0,
                                  children: items.map((url) {
                                    int index = items.indexOf(url);

                                    if (index == items.length) {
                                      return _buildProgressIndicator();
                                    } else {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  Directionality(
                                                    textDirection:
                                                    langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                    child:   compainDetails(items[index])),
                                            ),
                                          );
                                        },
                                        child: GridTile(
                                            child: Container(
                                                height: 300,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    items[index].Icon == null
                                                        ? new Container(
                                                      width: MediaQuery.of(context).size.width,
                                                            height: 90,
                                                            child: Image.asset(
                                                                'assets/images/compains.png', fit:  BoxFit.fill,),
                                                          )
                                                        : Container(
                                                      width: MediaQuery.of(context).size.width,
                                                            height: 90,
                                                            child:
                                                                Image.network(
                                                              'http://mypharma-order.com/files/images/manufacturers/large/' +
                                                                  items[index]
                                                                      .Icon, fit:  BoxFit.fill,
                                                            ),
                                                          ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 0),
                                                      child:  tListall[index]
                                                          .compainName!=null?
                                                      Text(
                                                        tListall[index]
                                                            .compainName,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 15),
                                                      ):
                                                      Text(
                                                        '',
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 15),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/compaincardhome.png'),
                                                  fit: BoxFit.fill,
                                                )))),
                                      );
                                    }
                                  }).toList()),
                            ))
                          : tListall == null
                              ? Container()
                              : Expanded(
                                  child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                                  child: GridView.count(
                                      controller: _sc,
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      childAspectRatio: (itemWidth / itemHeight),
                                      padding: const EdgeInsets.all(4.0),
                                      mainAxisSpacing: 4.0,
                                      crossAxisSpacing: 1.0,
                                      children: tListall.map((url) {
                                        int index = tListall.indexOf(url);

                                        if (index == tListall.length) {
                                          return _buildProgressIndicator();
                                        } else {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      Directionality(
                                                        textDirection:
                                                        langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                        child:  compainDetails(
                                                          tListall[index])),
                                                ),
                                              );
                                            },
                                            child: Container(
                                               // height: 25,
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    tListall[index].Icon ==
                                                        null
                                                        ? new Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: 90,
                                                      child: Image.asset(
                                                          'assets/images/compains.png', fit:  BoxFit.fill,),
                                                    )
                                                        : Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: 90,
                                                      child: Image
                                                          .network(
                                                        'http://mypharma-order.com/files/images/manufacturers/large/' +
                                                            tListall[
                                                            index]
                                                                .Icon,
                                                    fit:  BoxFit.fill, ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          0, 1, 0, 0),
                                                      child:
                                                      tListall[index]
                                                          .compainName!=null?Text(
                                                        tListall[index]
                                                            .compainName,
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .black,
                                                            fontSize: 15),
                                                      ):
                                                      Text(
                                                        '',
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .black,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    /*tListall[index]
                                                        .Address ==
                                                        "null"
                                                        ? Visibility(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .fromLTRB(
                                                            0,
                                                            1,
                                                            0,
                                                            1),
                                                        child: Text(
                                                          tListall[
                                                          index]
                                                              .Address,
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: Colors
                                                                  .black,
                                                              fontSize:
                                                              15),
                                                        ),
                                                      ),
                                                      visible: false,
                                                    )
                                                        : Visibility(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .fromLTRB(
                                                            0,
                                                            1,
                                                            0,
                                                            1),
                                                        child: Text(
                                                          tListall[
                                                          index]
                                                              .City + ' - ' +tListall[index].Address,
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: Colors
                                                                  .black,
                                                              fontSize:
                                                              15),
                                                        ),
                                                      ),
                                                      visible: true,
                                                    ),
                                                    tListall[index].phones == "null"
                                                        ? Visibility(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                                            child: Row(
                                                              children: <Widget>[
                                                                Image.asset('assets/images/phone.png'),
                                                                Padding(
                                                                  padding:
                                                                  EdgeInsets.fromLTRB(0, 15, 0, 15),
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Text(
                                                                        'items[index].phones',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 1,
                                                            color: Colors.grey,
                                                          ),
                                                        ],
                                                      ),
                                                      visible: false,
                                                    )
                                                        : GestureDetector(child: Visibility(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                            child: Row(
                                                              mainAxisAlignment:                                                       MainAxisAlignment.center,
                                                              children: <Widget>[
                                                                Image.asset('assets/images/phone.png'),
                                                                Padding(
                                                                  padding:
                                                                  EdgeInsets.fromLTRB(0, 15, 0, 15),
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Text(
                                                                        tListall[index].phones,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                      visible: true,
                                                    ))*/
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/compaincardhome.png'),
                                                      fit: BoxFit.fill,
                                                    ))),
                                          );
                                        }
                                      }).toList()),
                                )),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('error');
              } else {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.praimarydark)));
              }
            },
          ),
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
      citynum=preferences.getString('cityn');
      if (citynum == true) {
        if (activeSearch == true) {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": -1,
              "Search": searchePh,
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
        else {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": -1,
              "Search": "",
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
              "Search": "",
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
      }else{
        if (activeSearch == true) {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter":citynum,
              "Search": searchePh,
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
          else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": idcityPh,
              "Search": searchePh,
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
        else {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": citynum,
              "Search": "",
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
          else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": idcityPh,
              "Search": "",
            };
            final CompainRepository _repository = CompainRepository();

            response = await _repository.getcompainList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (response.code == '1') {
              for (int i = 0;
              i <= response.results.compains.listcompain.length;
              i++) {
                tList = new List.from(response.results.compains.listcompain);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListall == null) {
                  tListall = compainList + tList;
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
