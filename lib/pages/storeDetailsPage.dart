import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmas/Bloc/blocWare.dart';
import 'package:pharmas/Model/modelSubmit.dart';
import 'package:pharmas/Model/offerStoreDetails.dart';
import 'package:pharmas/Model/storeDrugDetails.dart';
import 'package:pharmas/Repository/WareRepository.dart';
import 'package:pharmas/Response/durgsResponse.dart';
import 'package:pharmas/Response/storeDetailsResponse.dart';
import 'package:pharmas/SharedPref.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/Durgs/durgDetails.dart';
import 'package:pharmas/pages/homePage.dart';
import 'package:pharmas/pages/offers/offerDetailsPage.dart';
import 'package:pharmas/pages/storelistdy.dart';
import 'package:pharmas/Bloc/blocDownloadState.dart';
import 'package:pharmas/pages/offers/offerDetailsStore.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class storeDetails extends StatefulWidget {
  final String nameStore;
  final String id;

  storeDetails(this.nameStore, this.id);

  @override
  _storeDetails createState() => new _storeDetails();
}

class _storeDetails extends State<storeDetails> {
  String sessionId,idu;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String isclickd, isclicko;
  var itemsWare = List<storeDrugModelDetail>();
  var itemsWareOff = List<storeOfferModelDetail>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var preferences;
  storeDetailsResponse response;
  SharedPref sharedPref = SharedPref();
  String orderL, orderSu;
  List<Music> orderLi;
  List<subList> orderLiSu;
  bool activeSearchWare = false;

  List<storeOfferModelDetail> tListallWareOff;
  List<storeOfferModelDetail> tListWareOff;
  List<storeOfferModelDetail> waresListOff;

  List<storeDrugModelDetail> tListallWare;
  List<storeDrugModelDetail> tListWare;
  List<storeDrugModelDetail> waresList;

  final _quantity = new TextEditingController();
  List<Music> myListOfIntegers = new List<Music>();
  int first = 0;
  TextEditingController editingControllerWare = TextEditingController();
  bool isLoadingWare = false;

  List<Music> gg = new List<Music>();
  List<subList> lastList = new List<subList>();
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
  getValueString() async {
    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    idu = preferences.getString('idu');

    setState(() {
      orderL = preferences.getString('mou');
      orderSu = preferences.getString('orderSu');

     if(orderL != null){
     if (orderL.length != 0) {
     orderLi = (json.decode(orderL) as List<dynamic>)
         .map<Music>((item) => Music.fromJson(item))
         .toList();
     orderLiSu = (json.decode(orderSu) as List<dynamic>)
         .map<subList>((item) => subList.fromJson(item))
         .toList();
     }
     }
    });

    Map<String, dynamic> data = {
      "Id": widget.id,
    };

    blocStateDe.downloadData(sessionId, data,langSave);

    final WareRepository _repository = WareRepository();

    response = await _repository.getStoreDetails(sessionId, data,langSave);
    if (response.code == '1') {
      setState(() {
        tListallWare = response.results.drugList.listStoreDrug;
        itemsWare.addAll(tListallWare);

        tListallWareOff = response.results.offerList.listStoreOffer;
        itemsWareOff.addAll(tListallWareOff);
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
    navigationPage();
    getValueString();
    activeSearchWare = false;

    //  navigationPage();
  }

  void filterSearchResultsWare(String query) {
    activeSearchWare = true;

    List<storeDrugModelDetail> dummySearchList = List<storeDrugModelDetail>();
    dummySearchList.addAll(tListallWare);
    List<storeOfferModelDetail> dummySearchListOff =
        List<storeOfferModelDetail>();
    dummySearchListOff.addAll(tListallWareOff);

    if (query.isNotEmpty || query != "") {
      List<storeDrugModelDetail> dummyListData = List<storeDrugModelDetail>();
      List<storeOfferModelDetail> dummyListDataOff =
          List<storeOfferModelDetail>();

      dummySearchList.forEach((item) {
        if (item.CommerceName.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });

      dummySearchListOff.forEach((itemOff) {
        if (itemOff.NameD.toLowerCase().contains(query.toLowerCase())) {
          dummyListDataOff.add(itemOff);
        }
      });

      setState(() {
        itemsWare.clear();
        itemsWare.addAll(dummyListData);
        itemsWareOff.clear();
        itemsWareOff.addAll(dummyListDataOff);
      });
      return;
    } else {
      setState(() {
        itemsWare.clear();
        itemsWare.addAll(tListallWare);
        itemsWareOff.clear();
        itemsWareOff.addAll(tListallWareOff);
      });
    }
  }

  PreferredSizeWidget _appBarWare() {
    if (activeSearchWare) {
      return AppBar(
        leading: Icon(Icons.search),
        title: TextField(
          onChanged: (value) {
            filterSearchResultsWare(value);
          },
          controller: editingControllerWare,
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
                activeSearchWare = false;
                editingControllerWare.clear();
                itemsWare.clear();
                itemsWare.addAll(tListallWare);
                itemsWareOff.clear();
                itemsWareOff.addAll(tListallWareOff);
              });
            },
          )
        ],
      );
    } else {
      return AppBar(
        title: Text(
          widget.nameStore.toString(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => setState(() => activeSearchWare = true),
          ),
        ],
        backgroundColor: Colors.praimarydark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
       // Navigator.of(context).pop(false);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
            textDirection:
            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: homePage(idu))
            ),
            ModalRoute.withName("/Home")
        );

      },
      child: Scaffold(
        appBar: _appBarWare(),
        resizeToAvoidBottomPadding: true,
        body: StreamBuilder<DownloadState>(
            stream: blocStateDe.dataState,
            // bloc get method that returns stream output.
            // initialData: DownloadState.NO_DOWNLOAD,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data) {
                  case DownloadState.NO_DOWNLOAD:
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.praimarydark)),
                    );
                  case DownloadState.DOWNLOADING:
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.praimarydark)),
                    );
                  case DownloadState.SUCCESS:
                    return SingleChildScrollView(
                      child: StreamBuilder(
                        stream: blocStateDe.subjectdetails.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<storeDetailsResponse> snapshot) {
                          if (snapshot.hasData) {
                            /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

                            return new Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                  child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        snapshot.data.results.city==null? Visibility(child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                'assets/images/location.png',
                                                height: 25,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 2, 10, 0),
                                                child: Text(
                                                 ' snapshot.data.results.city ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17),
                                                ),
                                              ),
                                              new Spacer(),
                                              GestureDetector(
                                                child: Image.asset(
                                                  'assets/images/mappharma.png',
                                                  height: 25,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (_, __, ___) => map(
                                                          snapshot.data
                                                              .results.lat,
                                                          snapshot
                                                              .data
                                                              .results
                                                              .long),
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                        ),visible: false,):
                                        Visibility(child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                'assets/images/location.png',
                                                height: 25,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 2, 10, 0),
                                                child: Text(
                                                  snapshot.data.results.city +
                                                      ' - ' +
                                                      snapshot
                                                          .data.results.address
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17),
                                                ),
                                              ),
                                              new Spacer(),
                                              GestureDetector(
                                                child: Image.asset(
                                                  'assets/images/mappharma.png',
                                                  height: 25,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (_, __, ___) => map(
                                                          snapshot.data
                                                              .results.lat,
                                                          snapshot
                                                              .data
                                                              .results
                                                              .long),
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                        ),visible: true,),

                                        Divider(
                                          height: 1,
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 20, 0, 0),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 5, 20, 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      AppLocalizations().lbDrug,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .praimarydark,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    new Spacer(),
                                                    isclickd == '1'
                                                        ? GestureDetector(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          3,
                                                                          0,
                                                                          0),
                                                              child: Icon(
                                                                Icons
                                                                    .keyboard_arrow_up,
                                                                color: Colors
                                                                    .praimarydark,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                isclickd = '2';
                                                              });
                                                            },
                                                          )
                                                        : GestureDetector(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          3,
                                                                          0,
                                                                          0),
                                                              child: Icon(
                                                                Icons
                                                                    .keyboard_arrow_down,
                                                                color: Colors
                                                                    .praimarydark,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                isclickd = '1';
                                                              });
                                                            },
                                                          )
                                                  ],
                                                ),
                                              ),
                                              snapshot
                                                          .data
                                                          .results
                                                          .drugList
                                                          .listStoreDrug
                                                          .length ==
                                                      0
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 10, 0, 10),
                                                      child: Text(
                                                          AppLocalizations().lbNotAvaD),
                                                    )
                                                  : activeSearchWare == true
                                                      ? Container(
                                                          child: Wrap(
                                                            children: <Widget>[
                                                              ListView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemCount:
                                                                      itemsWare
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
                                                                              10),
                                                                      child:
                                                                          GestureDetector(
                                                                        child:
                                                                            Container(
                                                                          decoration: BoxDecoration(
                                                                              image: DecorationImage(
                                                                            image:
                                                                                AssetImage('assets/images/carddurg.png'),
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          )),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                10,
                                                                                5,
                                                                                10,
                                                                                5),
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Column(
                                                                                        children: <Widget>[
                                                                                          Text(
                                                                                            itemsWare[index].CommerceName.toString(),
                                                                                            style: TextStyle(
                                                                                                color: Colors.praimarydark,fontWeight: FontWeight.bold
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      new Spacer(),
                                                                                      GestureDetector(
                                                                                        child: Icon(
                                                                                          Icons.add_shopping_cart,
                                                                                          color: Colors.praimarydark,
                                                                                        ),
                                                                                        onTap: () {
                                                                                          _quantity.clear();
                                                                                          orderLi != null ?
                                                                                          orderL.length != 0
                                                                                              ? orderLi[0].wareId.toString() == snapshot.data.results.id.toString()
                                                                                                  ? showDialog(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) {
                                                                                                        return showDialogwindowDone(snapshot.data.results.id, itemsWare[index].CommerceName.toString(), itemsWare[index].pharmap.toString(), itemsWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                                      })
                                                                                                  : showDialog(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) {
                                                                                                        return showDialogOk();
                                                                                                      })
                                                                                              : showDialog(
                                                                                                  context: context,
                                                                                                  builder: (BuildContext context) {
                                                                                                    return showDialogwindowDone(snapshot.data.results.id, itemsWare[index].CommerceName.toString(),
                                                                                                        itemsWare[index].pharmap.toString(), itemsWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                                  }): showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return showDialogwindowDone(snapshot.data.results.id, itemsWare[index].CommerceName.toString(),
                                                                                                    itemsWare[index].pharmap.toString(), itemsWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                              });
                                                                                        },
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child:
                                                                                Row(
                                                                                  children: <Widget>[ Text(
                                                                                    itemsWare[index]
                                                                                        .Strengths
                                                                                        .toString(),
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),],),),
                                                                                Padding(padding: EdgeInsets.fromLTRB(10, 5, 10, 5),child:
                                                                                Row(
                                                                                  children: <Widget>[ Text(
                                                                                    itemsWare[index]
                                                                                        .formD
                                                                                        .toString(),
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),],),),

                                                                                Padding(
                                                                                    padding:
                                                                                    EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                                    child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                                      Text(
                                                                                        itemsWare[index]
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
                                                                                  child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                                    Text(
                                                                                      AppLocalizations().lbGePrice   +' : '+
                                                                                          itemsWare[index]
                                                                                          .Price
                                                                                          .toString().split('.')[0],
                                                                                      style: TextStyle(
                                                                                          color: Colors.black),
                                                                                    ),
                                                                                  ],),)
                                                                              ),
                                                                                Padding(
                                                                                    padding:
                                                                                    EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                                    child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                                      Text(
                                                                                   AppLocalizations().lbPhPrice   +' : '+  itemsWare[index]
                                                                                            .pharmap
                                                                                            .toString().split('.')[0],
                                                                                        style: TextStyle(
                                                                                            color: Colors.black),
                                                                                      ),
                                                                                    ],),)
                                                                                ),
                                                                                Padding(
                                                                                    padding:
                                                                                    EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                                    child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                                      Text(
                                                                                        AppLocalizations().lbExDate+' : '+  itemsWare[index]
                                                                                            .exdate
                                                                                            .toString().substring(0,10),
                                                                                        style: TextStyle(
                                                                                            color: Colors.black),
                                                                                      ),
                                                                                    ],),)
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
                                                                              pageBuilder: (_, __, ___) =>
                                                                                  Directionality(
                                                                                    textDirection:
                                                                                    langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                                                    child:durgDetails(itemsWare[index].CommerceName,
                                                                                        itemsWare[index].id,'2')),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  })
                                                            ],
                                                          ),
                                                        )
                                                      : tListallWare == null
                                                          ? Container()
                                                          : isclickd == '1'?
                                              Visibility(
                                                visible: false,child:Container(
                                                child: Wrap(
                                                  children: <
                                                      Widget>[
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: tListallWare.length,
                                                        itemBuilder: (BuildContext ctxt, int index) {
                                                          return new Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                10),
                                                            child:
                                                            GestureDetector(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      image:
                                                                      AssetImage('assets/images/carddurg.png'),
                                                                      fit:
                                                                      BoxFit.fill,
                                                                    )),
                                                                child:
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      10,
                                                                      5,
                                                                      10,
                                                                      5),
                                                                  child:
                                                                  Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  tListallWare[index].CommerceName.toString(),
                                                                                  style: TextStyle(
                                                                                      color: Colors.praimarydark,fontWeight: FontWeight.bold
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            GestureDetector(
                                                                              child: Icon(
                                                                                Icons.add_shopping_cart,
                                                                                color: Colors.praimarydark,
                                                                              ),
                                                                              onTap: () {
                                                                                _quantity.clear();

                                                                                orderLi != null ?
                                                                                orderL.length != 0
                                                                                    ? orderLi[0].wareId.toString() == snapshot.data.results.id.toString()
                                                                                    ? showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDone(snapshot.data.results.id,
                                                                                          tListallWare[index].CommerceName.toString(),
                                                                                          tListallWare[index].pharmap.toString(),
                                                                                          tListallWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogOk();
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDone(snapshot.data.results.id, tListallWare[index].CommerceName.toString(), tListallWare[index].pharmap.toString(), tListallWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                    }):showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDone(snapshot.data.results.id, tListallWare[index].CommerceName.toString(), tListallWare[index].pharmap.toString(), tListallWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                    });
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child:
                                                                      Row(
                                                                        children: <Widget>[ Text(
                                                                          tListallWare[index]
                                                                              .Strengths
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),],),),
                                                                      Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child:
                                                                      Row(
                                                                        children: <Widget>[ Text(
                                                                          tListallWare[index]
                                                                              .formD
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),],),),

                                                                      Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              tListallWare[index]
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
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbGePrice+' : '+
                                                                                  tListallWare[index]
                                                                                  .Price
                                                                                  .toString().split('.')[0],
                                                                              style: TextStyle(
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ],),)
                                                                      ),
                                                                      Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbPhPrice+' : '+  tListallWare[index]
                                                                                  .pharmap
                                                                                  .toString().split('.')[0],
                                                                              style: TextStyle(
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ],),)
                                                                      )
, Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbExDate+' : '+  tListallWare[index]
                                                                                  .exdate
                                                                                  .toString().substring(0,10),
                                                                              style: TextStyle(
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ],),)
                                                                      ),
                                                                      Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              tListallWare[index]
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
                                                              ),
                                                              onTap:
                                                                  () {
                                                                Navigator.of(context).push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) =>
                                                                        Directionality(
                                                                          textDirection:
                                                                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                                          child:durgDetails(tListallWare[index].CommerceName,
                                                                              tListallWare[index].id,'2')),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                  ],
                                                ),
                                              )):
                                              Visibility(
                                                visible: true,child:Container(
                                                child: Wrap(
                                                  children: <
                                                      Widget>[
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: tListallWare.length,
                                                        itemBuilder: (BuildContext ctxt, int index) {
                                                          return new Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                10),
                                                            child:
                                                            GestureDetector(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      image:
                                                                      AssetImage('assets/images/carddurg.png'),
                                                                      fit:
                                                                      BoxFit.fill,
                                                                    )),
                                                                child:
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      10,
                                                                      5,
                                                                      10,
                                                                      5),
                                                                  child:
                                                                  Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  tListallWare[index].CommerceName.toString(),
                                                                                  style: TextStyle(
                                                                                    color: Colors.praimarydark,fontWeight: FontWeight.bold
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            GestureDetector(
                                                                              child: Icon(
                                                                                Icons.add_shopping_cart,
                                                                                color: Colors.praimarydark,
                                                                              ),
                                                                              onTap: () {
                                                                                _quantity.clear();

                                                                                orderLi != null ?
                                                                                orderL.length != 0
                                                                                    ? orderLi[0].wareId.toString() == snapshot.data.results.id.toString()
                                                                                    ? showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDone(
                                                                                          snapshot.data.results.id,
                                                                                          tListallWare[index].CommerceName.toString(),
                                                                                          tListallWare[index].pharmap.toString(),
                                                                                          tListallWare[index].id.toString(),
                                                                                          snapshot.data.results.storeName);
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogOk();
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDone(snapshot.data.results.id, tListallWare[index].CommerceName.toString(), tListallWare[index].pharmap.toString(), tListallWare[index].id.toString(), snapshot.data.results.storeName);
                                                                                    }):
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDone(
                                                                                          snapshot.data.results.id,
                                                                                          tListallWare[index].CommerceName.toString(),
                                                                                          tListallWare[index].pharmap.toString(),
                                                                                          tListallWare[index].id.toString(),
                                                                                          snapshot.data.results.storeName);
                                                                                    });
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child:
                                                                      Row(
                                                                        children: <Widget>[ Text(
                                                                          tListallWare[index]
                                                                              .Strengths
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),],),),
                                                                      Padding(padding: EdgeInsets.fromLTRB(10, 5, 10, 5),child:
                                                                      Row(
                                                                        children: <Widget>[ Text(
                                                                          tListallWare[index]
                                                                              .formD
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),],),),
                                                                      Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              tListallWare[index]
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
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbGePrice+' : '+
                                                                                  tListallWare[index]
                                                                                  .Price
                                                                                  .toString().split('.')[0],
                                                                              style: TextStyle(
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ],),)
                                                                      ),
                                                                      Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbPhPrice+' : '+  tListallWare[index]
                                                                                  .pharmap
                                                                                  .toString().split('.')[0],
                                                                              style: TextStyle(
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ],),)
                                                                      )
,Padding(
                                                                          padding:
                                                                          EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                          child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(children: <Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbExDate+' : '+  tListallWare[index]
                                                                                  .exdate
                                                                                  .toString().substring(0,10),
                                                                              style: TextStyle(
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ],),)
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap:
                                                                  () {
                                                                Navigator.of(context).push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) =>
                                                                        Directionality(
                                                                          textDirection:
                                                                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                                          child:durgDetails(tListallWare[index].CommerceName,
                                                                              tListallWare[index].id,'2')),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                  ],
                                                ),
                                              ) ,)
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 20, 0, 0),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 5, 20, 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      AppLocalizations().lbOffer,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .praimarydark,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    new Spacer(),
                                                    isclicko== '1'
                                                        ? GestureDetector(
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets
                                                            .fromLTRB(
                                                            0,
                                                            3,
                                                            0,
                                                            0),
                                                        child: Icon(
                                                          Icons
                                                              .keyboard_arrow_up,
                                                          color: Colors
                                                              .praimarydark,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          isclicko = '2';
                                                        });
                                                      },
                                                    )
                                                        : GestureDetector(
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets
                                                            .fromLTRB(
                                                            0,
                                                            3,
                                                            0,
                                                            0),
                                                        child: Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: Colors
                                                              .praimarydark,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          isclicko = '1';
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                              snapshot
                                                          .data
                                                          .results
                                                          .offerList
                                                          .listStoreOffer
                                                          .length ==
                                                      0
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 10, 0, 10),
                                                      child: Text(
                                                          AppLocalizations().lbNotAvaO),
                                                    )
                                                  : activeSearchWare == true
                                                      ? Container(
                                                          child: Wrap(
                                                            children: <Widget>[
                                                              ListView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemCount:
                                                                      itemsWareOff
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
                                                                          decoration:
                                                                              BoxDecoration(image: DecorationImage(image:
                                                                              itemsWareOff[index].gift == "" ? AssetImage('assets/images/discount.jpg') : AssetImage('assets/images/gift.jpg'), fit: BoxFit.fill)),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                10,
                                                                                15,
                                                                                10,
                                                                                15),
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Column(
                                                                                        children: <Widget>[
                                                                                         Container(child: Text(
                                                                                           itemsWareOff[index].NameD.toString(),
                                                                                           overflow: TextOverflow.ellipsis,

                                                                                           style: TextStyle(
                                                                                               color: Colors.praimarydark,fontWeight: FontWeight.bold
                                                                                           ),
                                                                                         ),width: 90,),
                                                                                        ],
                                                                                      ),
                                                                                      new Spacer(),

                                                                                      GestureDetector(
                                                                                        child: Icon(
                                                                                          Icons.add_shopping_cart,
                                                                                          color: Colors.praimarydark,
                                                                                        ),
                                                                                        onTap: () {
                                                                                          _quantity.clear();

                                                                                          orderLi != null ?
                                                                                          orderL.length != 0
                                                                                              ? orderLi[0].wareId.toString() == snapshot.data.results.id.toString()
                                                                                                  ? showDialog(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) {
                                                                                                        return showDialogwindowDoneOffer(snapshot.data.results.id, itemsWareOff[index].NameD.toString(), itemsWareOff[index].Tprice.toString(), itemsWareOff[index].id.toString(), itemsWareOff[index].gift.toString(), itemsWareOff[index].discount.toString(), itemsWareOff[index].wareN.toString());
                                                                                                      })
                                                                                                  : showDialog(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) {
                                                                                                        return showDialogOk();
                                                                                                      })
                                                                                              : showDialog(
                                                                                                  context: context,
                                                                                                  builder: (BuildContext context) {
                                                                                                    return showDialogwindowDoneOffer(snapshot.data.results.id, itemsWareOff[index].NameD.toString(), itemsWareOff[index].Tprice.toString(), itemsWareOff[index].id.toString(), itemsWareOff[index].gift.toString(), itemsWareOff[index].discount.toLowerCase(), itemsWareOff[index].wareN.toString());
                                                                                                  }):showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return showDialogwindowDoneOffer(snapshot.data.results.id, itemsWareOff[index].NameD.toString(), itemsWareOff[index].Tprice.toString(), itemsWareOff[index].id.toString(), itemsWareOff[index].gift.toString(), itemsWareOff[index].discount.toLowerCase(), itemsWareOff[index].wareN.toString());
                                                                                              });
                                                                                        },
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Row(
                                                                                  children: <Widget>[

                                                                                    Padding(
                                                                                      child: Text(itemsWareOff[
                                                                                      index]
                                                                                          .man,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                                                                                      padding:
                                                                                      EdgeInsets
                                                                                          .fromLTRB(
                                                                                          15,
                                                                                          5,
                                                                                          15,
                                                                                          5),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding:
                                                                                  EdgeInsets.fromLTRB(
                                                                                      15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                        child: itemsWareOff[index].gift==null?
                                                                                        Text(AppLocalizations().lbDis+' : '+itemsWareOff[
                                                                                        index]
                                                                                            .discount):
                                                                                        Text(AppLocalizations().lbGift+' : ' +itemsWareOff[
                                                                                        index]
                                                                                            .gift),),
                                                                                      new Spacer(),
                                                                                      itemsWareOff[
                                                                                      index]
                                                                                          .DreugExDate=='null'?  Visibility(visible:false,child:
                                                                                      Padding(
                                                                                        padding: EdgeInsets
                                                                                            .fromLTRB(15, 5,
                                                                                            15, 5),
                                                                                        child: Row(
                                                                                          children: <
                                                                                              Widget>[

                                                                                            Text(
                                                                                                AppLocalizations().lbDrugEx+' : '),

                                                                                          ],
                                                                                        ),
                                                                                      )):
                                                                                      Visibility(visible:true,child: Padding(
                                                                                        padding: EdgeInsets
                                                                                            .fromLTRB(5, 5,
                                                                                            5, 5),
                                                                                        child: Row(
                                                                                          children: <
                                                                                              Widget>[

                                                                                            Text(
                                                                                                AppLocalizations().lbDrugEx+' : '),
                                                                                            Padding(
                                                                                              child: Text(itemsWareOff[
                                                                                              index]
                                                                                                  .DreugExDate.substring(0,10)),
                                                                                              padding: EdgeInsets
                                                                                                  .fromLTRB(
                                                                                                  0,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ))

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
                                                                                              AppLocalizations().lbPhPrice+' : '),
                                                                                          Padding(
                                                                                            child: Text(itemsWareOff[
                                                                                            index]
                                                                                                .Price.split('.')[0]),
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
                                                                                                AppLocalizations().lbGePrice+' : '),
                                                                                            Padding(
                                                                                              child: Text(itemsWareOff[
                                                                                              index]
                                                                                                  .NormalPrice.split('.')[0]),
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
                                                                                              AppLocalizations().lbQuan+' : '),
                                                                                          Padding(
                                                                                            child: Text(itemsWareOff[
                                                                                            index]
                                                                                                .quantity),
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
                                                                                                AppLocalizations().lbToPrice+' : '),
                                                                                            Padding(
                                                                                              child: Text(itemsWareOff[
                                                                                              index]
                                                                                                  .Tprice.split('.')[0]),
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
                                                                                      child: Row(children: <Widget>[
                                                                                        Row(
                                                                                          children: <Widget>[
                                                                                            Text(
                                                                                                AppLocalizations().lbExDateOff+' : '),
                                                                                            Padding(
                                                                                              padding:
                                                                                              EdgeInsets
                                                                                                  .fromLTRB(
                                                                                                  5,
                                                                                                  0,
                                                                                                  5,
                                                                                                  0),
                                                                                              child: Text(itemsWareOff[
                                                                                              index]
                                                                                                  .exDate.substring(0,10)),
                                                                                            ),
                                                                                          ],
                                                                                        ),new Spacer(),
                                                                                       ],)


                                                                                   ,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .push(
                                                                            PageRouteBuilder(
                                                                              pageBuilder: (_, __, ___) =>
                                                                                  Directionality(
                                                                                    textDirection:
                                                                                    langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                                                    child:offerDetailsStore(itemsWareOff[index])),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  })
                                                            ],
                                                          ),
                                                        )
                                                      : tListallWare == null
                                                          ? Container()
                                                          :isclicko=='1'?
                                              Visibility(
                                                  visible: false,child: Container(
                                                child: Wrap(
                                                  children: <
                                                      Widget>[
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: tListallWareOff.length,
                                                        itemBuilder: (BuildContext ctxt, int index) {
                                                          return new Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                0),
                                                            child:
                                                            GestureDetector(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(image: DecorationImage(image: tListallWareOff[index].gift == "" ? AssetImage('assets/images/discount.jpg') : AssetImage('assets/images/gift.jpg'), fit: BoxFit.fill)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Container(child: Text(
                                                                                  tListallWareOff[index].NameD.toString(),
                                                                                  overflow: TextOverflow.ellipsis,

                                                                                  style: TextStyle(
                                                                                      color: Colors.praimarydark,fontWeight: FontWeight.bold
                                                                                  ),
                                                                                ),width: 90,),

                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            GestureDetector(
                                                                              child: Icon(
                                                                                Icons.add_shopping_cart,
                                                                                color: Colors.praimarydark,
                                                                              ),
                                                                              onTap: () {
                                                                                _quantity.clear();

                                                                                orderLi != null ?
                                                                                orderL.length != 0
                                                                                    ? orderLi[0].wareId.toString() == snapshot.data.results.id.toString()
                                                                                    ? showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDoneOffer(snapshot.data.results.id, tListallWareOff[index].NameD.toString(), tListallWareOff[index].Tprice.toString(), tListallWareOff[index].id.toString(), tListallWareOff[index].gift.toString(), tListallWareOff[index].discount.toString(), tListallWareOff[index].wareN.toString());
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogOk();
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDoneOffer(snapshot.data.results.id, tListallWareOff[index].NameD.toString(), tListallWareOff[index].Tprice.toString(), tListallWareOff[index].id.toString(), tListallWareOff[index].gift.toString(), tListallWareOff[index].discount.toLowerCase(), tListallWareOff[index].wareN.toString());
                                                                                    }):showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDoneOffer(snapshot.data.results.id, tListallWareOff[index].NameD.toString(), tListallWareOff[index].Tprice.toString(), tListallWareOff[index].id.toString(), tListallWareOff[index].gift.toString(), tListallWareOff[index].discount.toLowerCase(), tListallWareOff[index].wareN.toString());
                                                                                    });
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Text(
                                                                              tListallWareOff[index].Tprice.toString().split('.')[0],
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                            new Spacer(),
                                                                            Text(
                                                                              tListallWareOff[index].gift == null ?
                                                                              tListallWareOff[index].discount.toString() : tListallWareOff[index].gift.toString(),
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap:
                                                                  () {
                                                                Navigator.of(context).push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) =>
                                                                        Directionality(
                                                                            textDirection:
                                                                            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                                            child:   offerDetailsStore(tListallWareOff[index])),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                  ],
                                                ),
                                              ))

                                              :
                                              Visibility(
                                                visible: true,child: Container(
                                                child: Wrap(
                                                  children: <
                                                      Widget>[
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: tListallWareOff.length,
                                                        itemBuilder: (BuildContext ctxt, int index) {
                                                          return new Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                0),
                                                            child:
                                                            GestureDetector(
                                                              child:
                                                              Container(
                                                                decoration: BoxDecoration(image: DecorationImage(image: tListallWareOff[index].gift == "" ? AssetImage('assets/images/discount.jpg') : AssetImage('assets/images/gift.jpg'), fit: BoxFit.fill)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Container(child: Text(
                                                                                  tListallWareOff[index].NameD.toString(),
                                                                                  overflow: TextOverflow.ellipsis,

                                                                                  style: TextStyle(
                                                                                      color: Colors.praimarydark,fontWeight: FontWeight.bold
                                                                                  ),
                                                                                ),width: 90,),
                                                                                       ],
                                                                            ),
                                                                            new Spacer(),

                                                                            GestureDetector(
                                                                              child: Icon(
                                                                                Icons.add_shopping_cart,
                                                                                color: Colors.praimarydark,
                                                                              ),
                                                                              onTap: () {
                                                                                _quantity.clear();

                                                                                orderLi != null ?
                                                                                orderL.length != 0
                                                                                    ? orderLi[0].wareId.toString() == snapshot.data.results.id.toString()
                                                                                    ? showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDoneOffer(snapshot.data.results.id, tListallWareOff[index].NameD.toString(), tListallWareOff[index].Tprice.toString(), tListallWareOff[index].id.toString(), tListallWareOff[index].gift.toString(), tListallWareOff[index].discount.toString(), tListallWareOff[index].wareN.toString());
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogOk();
                                                                                    })
                                                                                    : showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDoneOffer(snapshot.data.results.id, tListallWareOff[index].NameD.toString(), tListallWareOff[index].Tprice.toString(), tListallWareOff[index].id.toString(), tListallWareOff[index].gift.toString(), tListallWareOff[index].discount.toLowerCase(), tListallWareOff[index].wareN.toString());
                                                                                    }): showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return showDialogwindowDoneOffer(snapshot.data.results.id, tListallWareOff[index].NameD.toString(), tListallWareOff[index].Tprice.toString(), tListallWareOff[index].id.toString(), tListallWareOff[index].gift.toString(), tListallWareOff[index].discount.toLowerCase(), tListallWareOff[index].wareN.toString());
                                                                                    });
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        children: <Widget>[

                                                                          Padding(
                                                                            child: Text(tListallWareOff[
                                                                            index]
                                                                                .man,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                                                                            padding:
                                                                            EdgeInsets
                                                                                .fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                        EdgeInsets.fromLTRB(
                                                                            15, 5, 15, 5),
                                                                        child: Row(
                                                                          children: <Widget>[
                                                                            Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                              child: tListallWareOff[index].gift==null?
                                                                              Text(AppLocalizations().lbDis+' : '+tListallWareOff[
                                                                              index]
                                                                                  .discount):
                                                                              Text(AppLocalizations().lbGift+' : '+tListallWareOff[
                                                                              index]
                                                                                  .gift),),
                                                                            new Spacer(),
                                                                            tListallWareOff[
                                                                            index]
                                                                                .DreugExDate=='null'?  Visibility(visible:false,child:
                                                                            Padding(
                                                                              padding: EdgeInsets
                                                                                  .fromLTRB(15, 5,
                                                                                  15, 5),
                                                                              child: Row(
                                                                                children: <
                                                                                    Widget>[

                                                                                  Text(
                                                                                      AppLocalizations().lbDrugEx+' : '),

                                                                                ],
                                                                              ),
                                                                            )):
                                                                            Visibility(visible:true,child: Padding(
                                                                                  padding: EdgeInsets
                                                                                      .fromLTRB(5, 5,
                                                                                      5, 5),
                                                                                  child: Row(
                                                                                    children: <
                                                                                        Widget>[

                                                                                      Text(
                                                                                          AppLocalizations().lbDrugEx+' : '),
                                                                                      Padding(
                                                                                        child: Text(tListallWareOff[
                                                                                        index]
                                                                                            .DreugExDate.substring(0,10)),
                                                                                        padding: EdgeInsets
                                                                                            .fromLTRB(
                                                                                            0,
                                                                                            0,
                                                                                            0,
                                                                                            0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ))
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
                                                                                    AppLocalizations().lbPhPrice+' : '),
                                                                                Padding(
                                                                                  child: Text(tListallWareOff[
                                                                                  index]
                                                                                      .Price.split('.')[0]),
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
                                                                                      AppLocalizations().lbGePrice+' : '),
                                                                                  Padding(
                                                                                    child: Text(tListallWareOff[
                                                                                    index]
                                                                                        .NormalPrice.split('.')[0]),
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
                                                                                    AppLocalizations().lbQuan+' : '),
                                                                                Padding(
                                                                                  child: Text(tListallWareOff[
                                                                                  index]
                                                                                      .quantity),
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
                                                                                      AppLocalizations().lbToPrice+' : '),
                                                                                  Padding(
                                                                                    child: Text(tListallWareOff[
                                                                                    index]
                                                                                        .Tprice.split('.')[0]),
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
                                                                            child: Row(children: <Widget>[Row(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                    AppLocalizations().lbExDateOff+' : '),
                                                                                Padding(
                                                                                  padding:
                                                                                  EdgeInsets
                                                                                      .fromLTRB(
                                                                                      5,
                                                                                      0,
                                                                                      5,
                                                                                      0),
                                                                                  child: Text(tListallWareOff[
                                                                                  index]
                                                                                      .exDate.substring(0,10)),
                                                                                ),
                                                                              ],
                                                                            ),new Spacer(),
                                                                           ],),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap:
                                                                  () {
                                                                Navigator.of(context).push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) =>
                                                                        Directionality(
                                                                          textDirection:
                                                                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                                                          child:offerDetailsStore(tListallWareOff[index])),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                  ],
                                                ),
                                              ))
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                            );
                          } else if (snapshot.hasError) {
                            return Text('error');
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.praimarydark)),
                            );
                          }
                        },
                      ),
                    );
                }
              }
              return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),
              );
            }),
      ),
    );
  }

  Widget showDialogwindowDoneOffer(String wareId, String drugName, String price,
      String offerId, String gift, String dis, String wareN) {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,

      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill)),

          child: Form(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Text(
                    AppLocalizations().lbAddO,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {
                        gg.clear();
                        lastList.clear();
                        gg.add(Music(
                          session: idu,
                            offeId: int.parse(offerId),
                            wareId: int.parse(wareId),
                            quantity: 0,
                            wareN: wareN,
                            drugname: drugName,
                            drugprice: price,
                            drugid: 0,
                            dis: dis,
                            gift: gift));
                        lastList.add(subList(
                            offeId: int.parse(offerId),
                            quantity: 0,
                            drugid: 0));
                        _save(gg, lastList);

                        Navigator.of(context).pop();
                        //_buildSubmitFormCo(context, wareId, offerId,dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.praimarydark,
                      child: Center(
                        child: new Text(
                          AppLocalizations().lbOk,
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
      ),
    );
  }

  Widget showDialogOk() {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,

      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill)),

          child: Form(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Text(
                    AppLocalizations().lbOrederWare,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        //_buildSubmitFormCo(context, wareId, offerId,dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.praimarydark,
                      child: Center(
                        child: new Text(
                          AppLocalizations().lbOk,
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
      ),
    );
  }

  Widget showDialogAdd() {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,

      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill )),

          child: Form(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Text(
                      AppLocalizations().lbConfAdd,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        //_buildSubmitFormCo(context, wareId, offerId,dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.praimarydark,
                      child: Center(
                        child: new Text(
                          AppLocalizations().lbOk,
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
      ),
    );
  }

  Widget showDialogwindowDone(String wareId, String drugName, String price,
      String drugId, String wareN) {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,

      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill)),

          child: Form(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Text(
                      AppLocalizations().lbEnterQ+' : ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      filled: true,
                      hintText: AppLocalizations().lbQuan,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ), //can also add icon to the end of the textfiled
                      //  suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {
                        gg.clear();
                        lastList.clear();
                        gg.add(Music(
                            session: idu.toString(),

                            offeId: 0,
                            wareId: int.parse(wareId),
                            quantity: int.parse(_quantity.text),
                            drugname: drugName,
                            wareN: wareN,
                            drugprice: price,
                            drugid: int.parse(drugId)));
                        lastList.add(subList(
                            offeId: 0,
                            quantity: int.parse(_quantity.text),
                            drugid: int.parse(drugId)));
                        _save(gg, lastList);

                        Navigator.of(context).pop();
                        //_buildSubmitFormCo(context, wareId, offerId,dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.praimarydark,
                      child: Center(
                        child: new Text(
                          AppLocalizations().lbOk,
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
      ),
    );
  }



  _save(List<Music> myListOfStringss, List<subList> lastLi) async {
    print(myListOfStringss);

    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    orderL = preferences.getString('mou');
    orderSu = preferences.getString('orderSu');

    if (orderL != null) {
      orderLi = (json.decode(orderL) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();
      orderLiSu = (json.decode(orderSu) as List<dynamic>)
          .map<subList>((item) => subList.fromJson(item))
          .toList();
      String fgfh = json.encode(
        gg.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
      );
      String llist = json.encode(
        lastLi
            .map<Map<String, dynamic>>((music) => subList.toMap(music))
            .toList(),
      );

      List<Music> newlisst = (json.decode(fgfh) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();

      List<subList> newlisstLast = (json.decode(llist) as List<dynamic>)
          .map<subList>((item) => subList.fromJson(item))
          .toList();

      List list1 = orderLi;
      List list2 = newlisst;
      list1.addAll(list2);

      List list4 = orderLiSu;
      List list3 = newlisstLast;
      list4.addAll(list3);

      String last = json.encode(
        list1.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
      );
      print(last);
      sharedPrefs.setString('mou', last);

      String lastttloi = json.encode(
        list4
            .map<Map<String, dynamic>>((music) => subList.toMap(music))
            .toList(),
      );
      print(list4);
      sharedPrefs.setString('orderSu', lastttloi);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return showDialogAdd();
          });
    }
    else {
      String fgfh = json.encode(
        gg.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
      );

      sharedPrefs.setString('mou', fgfh);

      String llasilist = json.encode(
        lastLi
            .map<Map<String, dynamic>>((music) => subList.toMap(music))
            .toList(),
      );

      sharedPrefs.setString('orderSu', llasilist);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return showDialogAdd();
          });
    }
  }
}

class map extends StatefulWidget {
  final String lat;

  final String lon;

  map(this.lat, this.lon);

  @override
  _map createState() => new _map();
}

class _map extends State<map> {
  GoogleMapController mapController;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers;

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('Your Location'),
          position: LatLng(double.parse(widget.lat), double.parse(widget.lon)),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Your Location'))
    ].toSet();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getCurrentLocation();
    _createMarker();
    markers = _createMarker();
    //  markers = _createMarker();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new WillPopScope(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              markers: markers,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      double.parse(widget.lat), double.parse(widget.lon)),
                  zoom: 15.0),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              /* onMapCreated: (GoogleMapController controller) {

                _controller.complete(controller);

              },
*/
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Polyline> poly = {};
}
