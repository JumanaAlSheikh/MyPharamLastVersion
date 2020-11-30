import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmas/Model/offerListModel.dart';
import 'package:pharmas/Model/offerStoreDetails.dart';
import 'package:pharmas/Repository/offerRepository.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/homePage.dart';
import 'package:pharmas/pages/storeDetailsPage.dart';
import 'package:pharmas/pages/storelistdy.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:pharmas/Model/modelSubmit.dart';

class offerDetailsStore extends StatefulWidget {
  final storeOfferModelDetail offerItem;

  offerDetailsStore(this.offerItem);

  @override
  _offerDetailsStore createState() => new _offerDetailsStore();
}

class _offerDetailsStore extends State<offerDetailsStore> {
  String isSlected = '0';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  List<Music> gg = new List<Music>();
  String orderL,orderSu;
  List<subList> orderLiSu;
String idu;
  var fromdate = GlobalKey<FormState>();
  String dateD;
  ProgressDialog pr;
  List<Music> orderLi;
  var preferences;
  String sessionId;
  List<subList> lastList = new List<subList>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  intl.DateFormat dateFormat ;
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
  var preferences = await SharedPreferences.getInstance();
  sessionId = preferences.getString('sessionId');
  idu = preferences.getString('idu');
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
    dateFormat  =  intl.DateFormat("dd-MM-yyyy");
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
    //  navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(child:    Scaffold(
        appBar: AppBar(
          title: Text(
            widget.offerItem.wareN,
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
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/offerd.png'),
                      fit: BoxFit.cover)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  widget.offerItem.NameD +
                                      ' ( ' +
                                      ' ' +
                                      widget.offerItem.drugf +
                                      ' )',
                                  style: TextStyle(
                                      color: Colors.praimarydark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          widget.offerItem.gift == ""
                              ? Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '%' + ' ',
                                      style: TextStyle(
                                          color: Colors.praimarydark,
                                          fontSize: 17),
                                    ),
                                    Text(widget.offerItem.discount)
                                  ],
                                ),
                              ],
                            ),
                          )
                              : Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.card_giftcard,
                                      color: Colors.praimary,
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(
                                        widget.offerItem.gift,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.description,
                                      color: Colors.praimary,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(widget.offerItem.Description,
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.note,
                                      color: Colors.praimary,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(widget.offerItem.Notes,
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations().lbCreDate+' : ',
                                      style: TextStyle(
                                          color: Colors.praimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Padding(
                                      child: Text(
                                          widget.offerItem.CreateDate
                                              .substring(0, 10),
                                          style: TextStyle()),
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations().lbExDate+' : ',
                                      style: TextStyle(
                                          color: Colors.praimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Padding(
                                      child: Text(
                                          widget.offerItem.exDate
                                              .substring(0, 10),
                                          style: TextStyle()),
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(12, 20, 12, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations().lbPhPrice+' : ',
                                      style: TextStyle(
                                          color: Colors.praimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Padding(
                                      child: Text(widget.offerItem.Price.split('.')[0],
                                          style: TextStyle()),
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    )
                                  ],
                                ),
                                new Spacer(),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                                  child: Row(
                                    children: <Widget>[
                                      Text(AppLocalizations().lbGePrice+' : ',
                                          style: TextStyle(
                                              color: Colors.praimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      Padding(
                                        child: Text(
                                          widget.offerItem.NormalPrice.split('.')[0],
                                        ),
                                        padding:
                                        EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(AppLocalizations().lbQuan+' : ',
                                        style: TextStyle(
                                            color: Colors.praimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Padding(
                                      child: Text(
                                        widget.offerItem.quantity,
                                      ),
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    )
                                  ],
                                ),
                                new Spacer(),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Row(
                                    children: <Widget>[
                                      Text(AppLocalizations().lbToPrice+' : ',
                                          style: TextStyle(
                                              color: Colors.praimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      Padding(
                                        child: Text(
                                          widget.offerItem.Tprice.split('.')[0],
                                        ),
                                        padding:
                                        EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 20),
                            child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return showDialogwindow(
                                            int.parse(widget.offerItem.wareId),
                                            widget.offerItem.wareN,
                                            int.parse( widget.offerItem.id),
                                            widget.offerItem.gift.toString(),
                                            widget.offerItem.discount
                                                .toString());
                                      });
                                },
                                child: Container(
                                  width: 150,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                    child: Center(
                                        child: Image.asset(
                                          'assets/images/buy.png',
                                          height: 40,
                                          width: 40,
                                        )),
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
                ),
              ),
              height: MediaQuery.of(context).size.height,
            )
          ],
        )) ,
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

      },)


;
  }

  Widget showDialogwindowDone(int wareId, int offerId) {
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
                      AppLocalizations().lbSelectDate+' : ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          child:Visibility(
            child: Form(
              key: fromdate,
              child: DateTimeField(
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: DateTime.now(),
                      lastDate: DateTime(2100));
                },
                format: dateFormat,
                validator: (val) {
                  if (val != null) {
                    return null;
                  } else {
                    return AppLocalizations().lbDDate;
                  }
                },
                decoration: InputDecoration(labelText: AppLocalizations().lbDDate),
                //   initialValue: DateTime.now(), //Add this in your Code.
                // initialDate: DateTime(2017),
                onSaved: (value) {
                  dateD = value.toString().substring(0, 10);
                  debugPrint(value.toString());
                },
              ),
            ),
            visible: true,
          ))
                ,
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {
                        _buildSubmitFormCo(context, wareId, offerId, dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.red,
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
      ),
    );
  }

  Widget showDialogwindow(
      int wareId, String wareName, int offerId, String gift, String dis) {
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
                      AppLocalizations().lbBuyD,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.praimarydark),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: new RaisedButton(
                          onPressed: () {
                            gg.add(Music(
                                session: idu,

                                drugid: 0,
                                drugname: widget.offerItem.NameD,
                                drugprice: widget.offerItem. Tprice,
                                offeId: offerId,
                                quantity: 0,
                                wareId: wareId,
                                gift: gift,
                                dis: dis));

                            lastList.add(subList(
                                offeId: offerId,
                                quantity: 0,
                                drugid:  0));



                            _save(gg,lastList, wareName, wareId.toString());
                            Navigator.pop(context, true);

                            //  _buildSubmitFormCo(context, id, value, amount);
                          }
                          //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                          ,
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          color: Colors.praimarydark,
                          child: Center(
                            child: new Text(
                              AppLocalizations().lbyes,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: new RaisedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            _buildSubmitFormCo(context, wareId, offerId, '1/1/2020');

                            /*showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return showDialogwindowDone(
                                      int.parse(widget.offerItem.wareId),
                                     int.parse( widget.offerItem.id));
                                });*/
                            // _buildSubmitFormCo(context, wareId, offerId);
                          }
                          //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                          ,
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          color: Colors.red,
                          child: Center(
                            child: new Text(
                              AppLocalizations().lbno,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildSubmitFormCo(
      BuildContext context, int wareId, int offerId, String delivaryd) async {
    pr.show();
    fromdate.currentState.save();

    var preferences = await SharedPreferences.getInstance();
     sessionId = preferences.getString('sessionId');
    idu = preferences.getString('idu');

    List products = [];

    var productMap = {
      'DrugId': 0,
      'Quantity': 0,
      'OfferId': offerId,
    };

    products.add(productMap);

    print('final list of products');
    print(products);
    Map<String, dynamic> data = {
      "WarehouseId": wareId,
      "DeliveryDate": '1/1/2020',
      "OrderDrugs": products,
    };
    //  ProjectBloc().addProjectRevnue(data);
    // BankBloc().addBankCommission(data);

    final offerRepository _repository = offerRepository();
    registerResponse response =
    await _repository.submitOrderOffer(data, sessionId,langSave);

    //  GeneralResponse response = await _repository.addProjectRevnue(data);
    if (response.code == '1') {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Navigator.pop(context, true);
    }
    else {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Toast.show(
          response.msg.toString(),
          context,
          duration: 4,
          gravity: Toast.BOTTOM);

    }
  }

  _save(List<Music> myListOfStringss,List<subList> lastLi, String wareName, String wareId) async {

    preferences = await SharedPreferences.getInstance();

    orderL = preferences.getString('mou');
    orderSu = preferences.getString('orderSu');

    if (orderL != null) {
      orderLi = (json.decode(orderL) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();
      orderLiSu = (json.decode(orderSu) as List<dynamic>)
          .map<subList>((item) => subList.fromJson(item))
          .toList();
      if (orderLi[0].wareId.toString() ==
          widget.offerItem.wareId.toString()) {

        final SharedPreferences sharedPrefs =
        await SharedPreferences.getInstance();
        String fgfh = json.encode(
          gg.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
        );


        String llist = json.encode(
          lastLi.map<Map<String, dynamic>>((music) => subList.toMap(music)).toList(),
        );

        List<Music> newlisst = (json.decode(fgfh) as List<dynamic>)
            .map<Music>((item) => Music.fromJson(item))
            .toList();


        List<Music> newlisstLast = (json.decode(llist) as List<dynamic>)
            .map<Music>((item) => Music.fromJson(item))
            .toList();


        List list1 = orderLi;
        List list2 = newlisst;
        list1.addAll(list2);


        List list4 = orderLiSu;
        List list3 = newlisstLast;
        list4.addAll(list3);



        String last = json.encode(
          list1
              .map<Map<String, dynamic>>((music) => Music.toMap(music))
              .toList(),
        );
        print(last);
        sharedPrefs.setString('mou', last);


        String lastttloi = json.encode(
          list4.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
        );
        print(list4);
        sharedPrefs.setString('orderSu', lastttloi);



        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                Directionality(
                  textDirection:
                  langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child: storeDetails(wareName, wareId.toString())),
          ),
        );
      } else {
        Toast.show(
           AppLocalizations().lbOrederWare,
            context,
            duration: 4,
            gravity: Toast.BOTTOM);
      }
    } else {

      final SharedPreferences sharedPrefs =
      await SharedPreferences.getInstance();
      String fgfh = json.encode(
        gg.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
      );

      sharedPrefs.setString('mou', fgfh);

      String llasilist = json.encode(
        lastLi.map<Map<String, dynamic>>((music) => subList.toMap(music)).toList(),
      );


      sharedPrefs.setString('orderSu', llasilist);




      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              Directionality(
                textDirection:
                langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child:  storeDetails(wareName, wareId.toString())),
        ),
      );
    }
  }
}
