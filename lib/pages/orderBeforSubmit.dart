import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:pharmas/Bloc/blocHome.dart';
import 'package:pharmas/Repository/offerRepository.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/homePage.dart';
import 'package:pharmas/pages/storelistdy.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pharmas/Model/modelSubmit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class orderBeforSub extends StatefulWidget {

  @override
  _orderBeforSub createState() => new _orderBeforSub();
}

class _orderBeforSub extends State<orderBeforSub> {
  String sessionId, orderL,orderSu ,idu;
  var preferences;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  int totalP = 0 ;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  var fromdate = GlobalKey<FormState>();
  intl.DateFormat dateFormat ;
  String dateD;
  ProgressDialog pr;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<Music> orderLi;
List<subList> orderLiSu;
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
    idu = preferences.getString('idu');

    sessionId = preferences.getString('sessionId');
    setState(() {
      orderL = preferences.getString('mou');
      orderSu = preferences.getString('orderSu');

      orderLi = (json.decode(orderL) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();
      orderLiSu = (json.decode(orderSu) as List<dynamic>)
          .map<subList>((item) => subList.fromJson(item))
          .toList();
    });
    setState(() {
      for(int j=0;j<orderLi.length;j++) {
        if(  orderLi[j].offeId==0){
          totalP =totalP+(int.parse(orderLi[j].drugprice.split('.')[0])*orderLi[j].quantity);

        }else{
          if(orderLi[j].drugprice!="null") {
            totalP = totalP + int.parse(orderLi[j].drugprice.split('.')[0]);
          }
        }
      }
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
    initializeDateFormatting();
    dateFormat   = intl.DateFormat("dd-MM-yyyy");
    getValueString();
    navigationPage();

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
  delete(List<Music> alarmLih,List<subList> alarmsend, int index) async {
    setState(() {
      totalP = 0 ;
    });
    if(alarmLih.length==1){
      alarmLih.removeAt(index);

      alarmsend.removeAt(index);
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

     /* String last = json.encode(
        alarmLih.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
      );
      String lastSend = json.encode(
        alarmsend.map<Map<String, dynamic>>((music) => subList.toMap(music)).toList(),
      );
      print(last);*/
      sharedPrefs.remove('mou');
      sharedPrefs.remove('orderSu');
/*
      sharedPrefs.setString('mou', last);
      sharedPrefs.setString('orderSu', lastSend);*/
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

    //  getValueString();
    }
    else{
      alarmLih.removeAt(index);

      alarmsend.removeAt(index);
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      String last = json.encode(
        alarmLih.map<Map<String, dynamic>>((music) => Music.toMap(music)).toList(),
      );
      String lastSend = json.encode(
        alarmsend.map<Map<String, dynamic>>((music) => subList.toMap(music)).toList(),
      );
      print(last);
      sharedPrefs.setString('mou', last);
      sharedPrefs.setString('orderSu', lastSend);

      getValueString();
    }

  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: new Text(
            AppLocalizations().lbShoList,
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
        body:orderLi!=null?orderLi.length!=0?SingleChildScrollView(child:  Container(
          color: Colors.white,
          //  height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Column(children: <Widget>[
                    Text(AppLocalizations().lbWareN+' : ' + orderLi[0].wareN,style: TextStyle(fontWeight: FontWeight.bold,color:
                    Colors.praimarydark)),
                    Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Text(AppLocalizations().lbToPrice+': ' +  '$totalP'),)
                  ],)
              ),
              Column(children: <Widget>[ListView(children: <Widget>[
                Container(height:MediaQuery.of(context).size.height/1.5,child: ListView.builder(
                  itemCount: orderLi.length,
                  // Add one more item for progress indicator
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  itemBuilder: (BuildContext context, int index) {
                    return new Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                        child: Column(
                          children: <Widget>[
                            Container(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          orderLi[index].offeId==0?  Text(
                                            orderLi[index].drugname,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ):
                                          Text(
                                            AppLocalizations().lbOffDru +' : '+ orderLi[index].drugname,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                          ,
                                          new Spacer(),
                                          GestureDetector(child:  Icon(Icons.delete,color: Colors.praimary,),onTap: (){
                                            delete(orderLi,orderLiSu,index);

                                          },)
                                        ],
                                      ),
                                      orderLi[index].offeId==0?Padding(
                                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                        child: Row(
                                          children: <Widget>[
                                            Text(AppLocalizations().lbQuan+' : ' +
                                                orderLi[index].quantity.toString()),
                                            new Spacer(),
                                            Text(AppLocalizations().lbPrice+' : ' +
                                                orderLi[index].drugprice.split('.')[0] +
                                                ' ' +
                                                AppLocalizations().lbSp)
                                          ],
                                        ),
                                      ):
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                        child: Row(
                                          children: <Widget>[
                                            Text(orderLi[index].dis=='0.0'?AppLocalizations().lbGift+' : ' +
                                                orderLi[index].gift:AppLocalizations().lbDis+' : ' +
                                                orderLi[index].dis),
                                            new Spacer(),
                                            Text(AppLocalizations().lbToPrice+' : ' +
                                                orderLi[index].drugprice.split('.')[0] +
                                                ' ' +
                                                AppLocalizations().lbSp)
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                          ],
                        ));
                  },
                ),)],shrinkWrap: true,),],),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: GestureDetector(
                    onTap: () {
                      _buildSubmitFormCo(context,orderLiSu,dateD);

                      /*  showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showDialogwindowDone(
                                orderLi);
                          });*/
                    },
                    child: Container(
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Center(
                          child: Text(
                            AppLocalizations().lbSubmit,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.praimarydark),
                    )),
              )
            ],
          ),
        ),):Container():Container());
  }

  Widget showDialogwindowDone(List<Music> submitOrder) {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,

      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/alert.png'),fit: BoxFit.fill)),

          child: Form(
            child: Column(
              children: <Widget>[
                Center(child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child:
                  Text(
                   AppLocalizations().lbSelectDate+ ' : ',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.praimarydark),),),),
Padding(
  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),child:Visibility(child:  Form(
  key: fromdate,
  child: DateTimeField(
    onShowPicker: (context, currentValue) {
      return showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          initialDate:DateTime.now(),
          lastDate: DateTime(2100));
    },
    format: dateFormat,
    validator: (val) {
      if (val != null) {
        return null;
      } else {
        return AppLocalizations().lbinsertDate;
      }
    },
    decoration: InputDecoration(
        labelText:
        AppLocalizations().lbDDate),
    //   initialValue: DateTime.now(), //Add this in your Code.
    // initialDate: DateTime(2017),
    onSaved: (value) {
      dateD = value
          .toString()
          .substring(0, 10);
      debugPrint(
          value.toString());
    },
  ),
),visible: true,),),






                Padding(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                  child: new RaisedButton(
                      onPressed: () {

                        _buildSubmitFormCo(context,orderLiSu,dateD);
                      }
                      //  textColor: Colors.yellow,colorBrightness: Brightness.dark,
                      ,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color:Colors.praimarydark ,
                      child: Center(
                        child: new Text(
                          AppLocalizations().lbDone,
                          style: TextStyle(fontSize: 20,
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
  _buildSubmitFormCo(BuildContext context, List<subList> subOrd,String delivaryd) async {
      pr.show();
    //  fromdate.currentState.save();

      var preferences = await SharedPreferences.getInstance();
      String sessionId = preferences.getString('sessionId');



      List products = [];
      print(subOrd.length);

      for(int h=0;h<subOrd.length;h++){
        var productMap = {
          'DrugId': subOrd[h].drugid,
          'Quantity': subOrd[h].quantity,
          'OfferId': subOrd[h].offeId,
        };
        products.add(productMap);

      }




      print(products);
      print(subOrd);

      Map<String, dynamic> data = {
        "WarehouseId": orderLi[0].wareId,
        "DeliveryDate":  '1/1/2020',
        "OrderDrugs": products,
      };
      //  ProjectBloc().addProjectRevnue(data);
      // BankBloc().addBankCommission(data);

      final offerRepository _repository = offerRepository();
      registerResponse response =
      await _repository.submitOrderOffer(data,sessionId ,langSave);

      //  GeneralResponse response = await _repository.addProjectRevnue(data);
      if (response.code == '1') {
        pr.hide().then((isHidden) {
          print(isHidden);
        });

        preferences.remove('mou');
        preferences.remove('orderSu');

        Map<String, dynamic> data = {
          "PageSize": 10,
          "PageNumber": 1,
          "Filter": 1,
          "Search": "",
        };

        blocHome.getHomeList(sessionId, data,langSave);
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
            textDirection:
            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: homePage(''))
            ),
            ModalRoute.withName("/Home")
        );

      } else {
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


}
