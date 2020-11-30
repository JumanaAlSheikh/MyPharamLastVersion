import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:intl/intl.dart';
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Bloc/blocOffer.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Model/offerListModel.dart';
import 'package:pharmas/Repository/offerRepository.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/offerResponse.dart';
import 'package:pharmas/pages/offers/offerDetailsPage.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class offerList extends StatefulWidget {
  @override
  _offerList createState() => new _offerList();
}

class _offerList extends State<offerList> {
   List<offerAllList> offerList;
  static int pageOffer = 2;
   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
   FlutterLocalNotificationsPlugin();
  String seratextOffer;
   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

   String langSave;
  List<offerAllList> tListOffer;
  List<offerAllList> tListallOffer;
  TextEditingController editingControllerOffer = TextEditingController();

  ScrollController _scOffer = new ScrollController();
  bool isLoadingOffer = false;
  String sessionId;
  var preferences;
  City selectedUser;
  bool activeSearchOffer = false;
  List<City> citylist;
  offerResponse responseOffer;
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  var itemsOffer = List<offerAllList>();

  void filterSearchResults(String query) {
    activeSearchOffer = true;

    List<offerAllList> dummySearchList = List<offerAllList>();
    dummySearchList.addAll(tListallOffer);
    if (query.isNotEmpty) {
      List<offerAllList> dummyListData = List<offerAllList>();
      dummySearchList.forEach((item) {
        if (item.Durg.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        itemsOffer.clear();
        itemsOffer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        itemsOffer.clear();
        itemsOffer.addAll(tListallOffer);
      });
    }
  }

  getValueString() async {
    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    langSave = preferences.getString('lang');

    if (selectedUser == null) {
      Map<String, dynamic> data = {
        "PageSize": 10,
        "PageNumber": 1,
        "Filter": -1,
        "Search": "",
      };
      //  blocOffer.getOfferList(sessionId, data);

      final offerRepository _repository = offerRepository();

      responseOffer = await _repository.getOfferList(sessionId, data,langSave);
      setState(() {
        tListallOffer = responseOffer.results.offers.listOffer;
        itemsOffer.addAll(tListallOffer);
      });
    } else {
      Map<String, dynamic> data = {
        "PageSize": 10,
        "PageNumber": 1,
        "Filter": selectedUser.id,
        "Search": "",
      };
      final offerRepository _repository = offerRepository();

      responseOffer = await _repository.getOfferList(sessionId, data,langSave);
      setState(() {
        tListallOffer = responseOffer.results.offers.listOffer;
        itemsOffer.addAll(tListallOffer);
      });
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
    activeSearchOffer = false;
    getValueString();
    blocCity.getCity(langSave);

    //  _getMoreData(page);
    _scOffer.addListener(() {
      if (_scOffer.position.pixels == _scOffer.position.maxScrollExtent) {
        _getMoreData(pageOffer);
      }
    });
    //  navigationPage();
  }

  PreferredSizeWidget _appBar() {
    if (activeSearchOffer) {
      return AppBar(
        leading: Icon(Icons.search),
        title: TextField(
          onChanged: (value) {
            filterSearchResults(value);
            seratextOffer=value;
          },
          controller: editingControllerOffer,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white)),
            labelStyle: new TextStyle(color: Colors.white),
            hintText: "Enter Commerce Name",
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => setState(() => activeSearchOffer = false),
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
        title: Text("Offers"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => setState(() => activeSearchOffer = true),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _appBar(),
        //   resizeToAvoidBottomPadding: true,
        body: StreamBuilder(
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
                          Expanded(
                              child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 50.0),
                            child: DropdownButton<City>(
                              isExpanded: true,
                              iconEnabledColor: Colors.praimarydark,
                              hint: selectedUser == null
                                  ? Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: Text(
                                        'Filter by city',
                                        style: TextStyle(
                                            color: Colors.praimarydark),
                                      ),
                                    )
                                  : Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: Text(
                                          selectedUser.cityName.toString(),
                                          style: TextStyle(
                                              color: Colors.praimarydark)),
                                    ),
                              // value: selectedUser,
                              onChanged: (City Value) {
                                setState(() {
                                  selectedUser = Value;
                                  initState();
                                });
                              },

                              items: citylist.map((City user) {
                                return DropdownMenuItem<City>(
                                  value: user,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          user.cityName,
                                          style: TextStyle(
                                            color: Colors.praimarydark,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    activeSearchOffer == true
                        ? Expanded(
                        child: ListView.builder(
                          itemCount: itemsOffer.length + 1,
                          // Add one more item for progress indicator
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == itemsOffer.length) {
                              return _buildProgressIndicator();
                            } else {
                              return new Padding(
                                padding:
                                EdgeInsets.fromLTRB(10, 30, 10, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            offerDetails(itemsOffer[index]),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: itemsOffer[index].Gift ==
                                                ""
                                                ? AssetImage(
                                                'assets/images/discount.jpg')
                                                : AssetImage(
                                                'assets/images/gift.jpg'),
                                            fit: BoxFit.fill)),
                                    child: itemsOffer[index].Gift == ""
                                        ? Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              20, 0, 20, 5),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(0, 20,
                                                    0, 0),
                                                child: Container(
                                                  constraints:
                                                  new BoxConstraints(
                                                      maxWidth:
                                                      100),
                                                  child: Text(
                                                      itemsOffer[
                                                      index]
                                                          .Durg,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .praimarydark)),
                                                  height: 50,
                                                ),
                                              ),
                                              // new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(
                                                    0, 20, 0, 0),
                                                child: Container(
                                                    height: 50,

                                                    child: Text(
                                                      'Discount : ' +
                                                          itemsOffer[
                                                          index]
                                                              .Discount +
                                                          ' % ',
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Company : '),
                                                  Padding(
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .Price),
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                  )
                                                ],
                                              ),
                                              new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(15, 5,
                                                    15, 5),
                                                child: Row(
                                                  children: <
                                                      Widget>[
                                                    Text(
                                                        'Drug form : '),
                                                    Padding(
                                                      child: Text(itemsOffer[
                                                      index]
                                                          .DurgForm),
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          5,
                                                          0,
                                                          5,
                                                          0),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Pharma price : '),
                                                  Padding(
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .Price),
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                  )
                                                ],
                                              ),
                                              new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(15, 5,
                                                    15, 5),
                                                child: Row(
                                                  children: <
                                                      Widget>[
                                                    Text(
                                                        'General price : '),
                                                    Padding(
                                                      child: Text(itemsOffer[
                                                      index]
                                                          .NormalPrice),
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          5,
                                                          0,
                                                          5,
                                                          0),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Quantity : '),
                                                  Padding(
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .Quantity),
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                  )
                                                ],
                                              ),
                                              new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(15, 5,
                                                    15, 5),
                                                child: Row(
                                                  children: <
                                                      Widget>[
                                                    Text(
                                                        'Total price : '),
                                                    Padding(
                                                      child: Text(itemsOffer[
                                                      index]
                                                          .TotalPrice),
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          5,
                                                          0,
                                                          5,
                                                          0),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 15),
                                          child: Align(
                                            child: Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Expired Date  : '),
                                                  Padding(
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .ExpiryDate),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                        : Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              20, 0, 20, 5),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                  padding:
                                                  EdgeInsets
                                                      .fromLTRB(
                                                      0,
                                                      20,
                                                      0,
                                                      0),
                                                  child: Container(
                                                    constraints:
                                                    new BoxConstraints(
                                                        maxWidth:
                                                        100),
                                                    child: Text(
                                                        itemsOffer[
                                                        index]
                                                            .Durg,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .praimarydark)),
                                                    height: 50,
                                                  )),
                                              // new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(
                                                    0, 20, 0, 0),
                                                child: Container(
                                                    height: 50,

                                                    child: Text(
                                                      'Gift : ' +
                                                          itemsOffer[
                                                          index]
                                                              .Gift,
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Company : '),
                                                  Padding(
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .Price),
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                  )
                                                ],
                                              ),
                                              new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(15, 5,
                                                    15, 5),
                                                child: Row(
                                                  children: <
                                                      Widget>[
                                                    Text(
                                                        'Drug form : '),
                                                    Padding(
                                                      child: Text(itemsOffer[
                                                      index]
                                                          .DurgForm),
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          5,
                                                          0,
                                                          5,
                                                          0),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Pharma price : '),
                                                  Padding(
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .Price),
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                  )
                                                ],
                                              ),
                                              new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(15, 5,
                                                    15, 5),
                                                child: Row(
                                                  children: <
                                                      Widget>[
                                                    Text(
                                                        'General price : '),
                                                    Padding(
                                                      child: Text(itemsOffer[
                                                      index]
                                                          .NormalPrice),
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          5,
                                                          0,
                                                          5,
                                                          0),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),


                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Quantity : '),
                                                  Padding(
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .Quantity),
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                  )
                                                ],
                                              ),
                                              new Spacer(),
                                              Padding(
                                                padding: EdgeInsets
                                                    .fromLTRB(15, 5,
                                                    15, 5),
                                                child: Row(
                                                  children: <
                                                      Widget>[
                                                    Text(
                                                        'Total price : '),
                                                    Padding(
                                                      child: Text(itemsOffer[
                                                      index]
                                                          .TotalPrice),
                                                      padding: EdgeInsets
                                                          .fromLTRB(
                                                          5,
                                                          0,
                                                          5,
                                                          0),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              15, 5, 15, 15),
                                          child: Align(
                                            child: Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Expired Date  : '),
                                                  Padding(
                                                    padding:
                                                    EdgeInsets
                                                        .fromLTRB(
                                                        5,
                                                        0,
                                                        5,
                                                        0),
                                                    child: Text(itemsOffer[
                                                    index]
                                                        .ExpiryDate),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          controller: _scOffer,
                        ))
                        : tListallOffer == null
                            ? Container()
                            : Expanded(
                                child: ListView.builder(
                                itemCount: tListallOffer.length + 1,
                                // Add one more item for progress indicator
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == tListallOffer.length) {
                                    return _buildProgressIndicator();
                                  } else {
                                    return new Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 30, 10, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  offerDetails(tListallOffer[index]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: tListallOffer[index].Gift ==
                                                          ""
                                                      ? AssetImage(
                                                          'assets/images/discount.jpg')
                                                      : AssetImage(
                                                          'assets/images/gift.jpg'),
                                                  fit: BoxFit.fill)),
                                          child: tListallOffer[index].Gift == ""
                                              ? Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              20, 0, 20, 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(0, 20,
                                                                    0, 0),
                                                            child: Container(
                                                              constraints:
                                                                  new BoxConstraints(
                                                                      maxWidth:
                                                                          100),
                                                              child: Text(
                                                                  tListallOffer[
                                                                          index]
                                                                      .Durg,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .praimarydark)),
                                                              height: 50,
                                                            ),
                                                          ),
                                                          // new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 20, 0, 0),
                                                            child: Container(
                                                                height: 50,

                                                                child: Text(
                                                              'Discount : ' +
                                                                  tListallOffer[
                                                                          index]
                                                                      .Discount +
                                                                  ' % ',
                                                            )),
                                                          )
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          15, 5, 15, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Company : '),
                                                              Padding(
                                                                child: Text(tListallOffer[
                                                                index]
                                                                    .Price),
                                                                padding:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                    5,
                                                                    0,
                                                                    5,
                                                                    0),
                                                              )
                                                            ],
                                                          ),
                                                          new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15, 5,
                                                                15, 5),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    'Drug Form : '),
                                                                Padding(
                                                                  child: Text(tListallOffer[
                                                                  index]
                                                                      .DurgForm),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      0),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          15, 5, 15, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Pharma price : '),
                                                              Padding(
                                                                child: Text(tListallOffer[
                                                                index]
                                                                    .Price),
                                                                padding:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                    5,
                                                                    0,
                                                                    5,
                                                                    0),
                                                              )
                                                            ],
                                                          ),
                                                          new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15, 5,
                                                                15, 5),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    'General price : '),
                                                                Padding(
                                                                  child: Text(tListallOffer[
                                                                  index]
                                                                      .NormalPrice),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      0),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              15, 5, 15, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Quantity : '),
                                                              Padding(
                                                                child: Text(tListallOffer[
                                                                        index]
                                                                    .Quantity),
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                              )
                                                            ],
                                                          ),
                                                          new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15, 5,
                                                                    15, 5),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    'Total price : '),
                                                                Padding(
                                                                  child: Text(tListallOffer[
                                                                          index]
                                                                      .TotalPrice),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          5,
                                                                          0,
                                                                          5,
                                                                          0),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              15, 5, 15, 15),
                                                      child: Align(
                                                        child: Container(
                                                          child: Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Expired Date  : '),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                                child: Text(tListallOffer[
                                                                        index]
                                                                    .ExpiryDate),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              20, 0, 20, 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          20,
                                                                          0,
                                                                          0),
                                                              child: Container(
                                                                constraints:
                                                                    new BoxConstraints(
                                                                        maxWidth:
                                                                            100),
                                                                child: Text(
                                                                    tListallOffer[
                                                                            index]
                                                                        .Durg,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .praimarydark)),
                                                                height: 50,
                                                              )),
                                                          // new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 20, 0, 0),
                                                            child: Container(
                                                                height: 50,

                                                                child: Text(
                                                              'Gift : ' +
                                                                  tListallOffer[
                                                                          index]
                                                                      .Gift,
                                                            )),
                                                          )
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          15, 5, 15, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Company : '),
                                                              Padding(
                                                                child: Text(tListallOffer[
                                                                index]
                                                                    .Price),
                                                                padding:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                    5,
                                                                    0,
                                                                    5,
                                                                    0),
                                                              )
                                                            ],
                                                          ),
                                                          new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15, 5,
                                                                15, 5),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    'Drug form : '),
                                                                Padding(
                                                                  child: Text(tListallOffer[
                                                                  index]
                                                                      .DurgForm),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      0),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          15, 5, 15, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Pharma price : '),
                                                              Padding(
                                                                child: Text(tListallOffer[
                                                                index]
                                                                    .Price),
                                                                padding:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                    5,
                                                                    0,
                                                                    5,
                                                                    0),
                                                              )
                                                            ],
                                                          ),
                                                          new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15, 5,
                                                                15, 5),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    'General price : '),
                                                                Padding(
                                                                  child: Text(tListallOffer[
                                                                  index]
                                                                      .NormalPrice),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      0),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              15, 5, 15, 5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Quantity : '),
                                                              Padding(
                                                                child: Text(tListallOffer[
                                                                        index]
                                                                    .Quantity),
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                              )
                                                            ],
                                                          ),
                                                          new Spacer(),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15, 5,
                                                                    15, 5),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    'Total price : '),
                                                                Padding(
                                                                  child: Text(tListallOffer[
                                                                          index]
                                                                      .TotalPrice),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          5,
                                                                          0,
                                                                          5,
                                                                          0),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              15, 5, 15, 15),
                                                      child: Align(
                                                        child: Container(
                                                          child: Row(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Expired Date  : '),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                                child: Text(tListallOffer[
                                                                        index]
                                                                    .ExpiryDate),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                controller: _scOffer,
                              )),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('error');
            } else {
              return Text('load');
            }
          },
        ));
  }

  _getMoreData(int index) async {
    tListallOffer = new List();
    if (!isLoadingOffer) {
      setState(() {
        isLoadingOffer = true;
      });

      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');

      if (activeSearchOffer == true) {
        if (selectedUser == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": pageOffer,
            "Filter": -1,
            "Search": seratextOffer,
          };
          final offerRepository _repository = offerRepository();

          responseOffer = await _repository.getOfferList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (responseOffer.code == '1') {
            for (int i = 0; i <= responseOffer.results.offers.listOffer.length; i++) {
              tListOffer = new List.from(responseOffer.results.offers.listOffer);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoadingOffer = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListallOffer == null) {
                tListallOffer = offerList + tListOffer;
              } else {
                tListallOffer = tListallOffer + tListOffer;
              }

              pageOffer++;
            });
          } else {
            Toast.show(responseOffer.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        }
        else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": pageOffer,
            "Filter": selectedUser.id,
            "Search":seratextOffer,
          };
          final offerRepository _repository = offerRepository();

          responseOffer = await _repository.getOfferList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (responseOffer.code == '1') {
            for (int i = 0; i <= responseOffer.results.offers.listOffer.length; i++) {
              tListOffer = new List.from(responseOffer.results.offers.listOffer);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoadingOffer = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListallOffer == null) {
                tListallOffer = offerList + tListOffer;
              } else {
                tListallOffer = tListallOffer + tListOffer;
              }

              pageOffer++;
            });
          } else {
            Toast.show(responseOffer.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        }
      }
      else{
        if (selectedUser == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": pageOffer,
            "Filter": -1,
            "Search": "",
          };
          final offerRepository _repository = offerRepository();

          responseOffer = await _repository.getOfferList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (responseOffer.code == '1') {
            for (int i = 0; i <= responseOffer.results.offers.listOffer.length; i++) {
              tListOffer = new List.from(responseOffer.results.offers.listOffer);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoadingOffer = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListallOffer == null) {
                tListallOffer = offerList + tListOffer;
              } else {
                tListallOffer = tListallOffer + tListOffer;
              }

              pageOffer++;
            });
          } else {
            Toast.show(responseOffer.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
          }
        }
        else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": pageOffer,
            "Filter": selectedUser.id,
            "Search": "",
          };
          final offerRepository _repository = offerRepository();

          responseOffer = await _repository.getOfferList(sessionId, data,langSave);
//offerList = response.results.offers.listOffer;
          //   response = blocOffer.getOfferList(sessionId, data);
          if (responseOffer.code == '1') {
            for (int i = 0; i <= responseOffer.results.offers.listOffer.length; i++) {
              tListOffer = new List.from(responseOffer.results.offers.listOffer);
              //  tList.add(offerList[i]);
            }

            setState(() {
              isLoadingOffer = false;
              //  offerList.addAll(tList);
              //  offerList= new List.from(tList,tListall);
              if (tListallOffer == null) {
                tListallOffer = offerList + tListOffer;
              } else {
                tListallOffer = tListallOffer + tListOffer;
              }

              pageOffer++;
            });
          } else {
            Toast.show(responseOffer.msg.toString(), context,
                duration: 4, gravity: Toast.BOTTOM);
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
          opacity: isLoadingOffer ? 1.0 : 00,
          child: new CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),
        ),
      ),
    );
  }
}
