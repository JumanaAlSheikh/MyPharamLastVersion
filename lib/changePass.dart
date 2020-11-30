import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/login.dart';
import 'package:pharmas/pages/splashActivity.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class changeP extends StatefulWidget {
  @override
  _changeP createState() => new _changeP();
}

class _changeP extends State<changeP> {
  final newPass = TextEditingController();
  final ConfirmNew = TextEditingController();
  final oldPass = TextEditingController();
  var preferences;
  String old;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  Future navigationPageL() async {
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

  String sessionId,email,phaN,phacN,address,long,lat,licNum,status,cityId,woH,synNum,workH,PharmPic,SynPic;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int istrue = 0 ;
int isold=0;
  ProgressDialog pr;
  Future navigationPage() async {

    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    email = preferences.getString('emailp');
    phaN = preferences.getString('pharman');
    phacN = preferences.getString('pharmasi');
    long = preferences.getString('long');
    lat = preferences.getString('lat');
    cityId = preferences.getString('cityn');
    address = preferences.getString('adress');
    licNum = preferences.getString('licnum');
    status = preferences.getString('statusu');
    woH = preferences.getString('workhour');
    synNum = preferences.getString('SyndicateNumber');
    PharmPic = preferences.getString('PharmacyPhoto');
    SynPic = preferences.getString('SyndicateIdPhoto');
old=preferences.getString('oldPass');

  }
  @override
  void initState() {
    // blocCity.getCity();
    navigationPageL();
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

    //  navigationPage();
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
    return new Scaffold(appBar: AppBar(
      leading: GestureDetector(
        child: Icon(Icons.arrow_back_ios),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(AppLocalizations().lbChangeP),

    ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/registration.jpg'),
                fit: BoxFit.fill,
              )),
          child: Container(
            width: MediaQuery.of(context).size.width,
            //  height: MediaQuery.of(context).size.height,

            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                          child: TextField(
                            controller: oldPass,
                            cursorColor: Colors.praimarydark,
                            style: TextStyle(color: Colors.praimarydark),
                            decoration: InputDecoration(
                              filled: true,

                              fillColor: Colors.transparent,
                              hintText: AppLocalizations().lbOldP,
                              hintStyle: TextStyle(color: Colors.praimarydark,),
                              //can also add icon to the end of the textfiled
                              //  suffixIcon: Icon(Icons.remove_red_eye),
                            ),
                          ),
                        ),
                        isold==0?Visibility(child:  Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Text(AppLocalizations().lbOldPW,style: TextStyle(color: Colors.red),),
                        ),visible: false,):
                        Visibility(child:  Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Row(children: <Widget>[Text(AppLocalizations().lbOldPW,style: TextStyle(color: Colors.red),)],),
                        ),visible: true,)

                        ,
                        Padding(padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: TextField(
                            controller: newPass,
                            cursorColor: Colors.praimarydark,
                            style: TextStyle(color: Colors.praimarydark),
                            decoration: InputDecoration(
                              filled: true,

                              fillColor: Colors.transparent,
                              hintText: AppLocalizations().lbNewP,
                              hintStyle: TextStyle(color: Colors.praimarydark,),
                              //can also add icon to the end of the textfiled
                              //  suffixIcon: Icon(Icons.remove_red_eye),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: TextField(
                            controller: ConfirmNew,
                            cursorColor: Colors.praimarydark,
                            style: TextStyle(color: Colors.praimarydark),
                            decoration: InputDecoration(
                              filled: true,

                              fillColor: Colors.transparent,
                              hintText: AppLocalizations().lbCpass,
                              hintStyle: TextStyle(color: Colors.praimarydark,),
                              //can also add icon to the end of the textfiled
                              //  suffixIcon: Icon(Icons.remove_red_eye),
                            ),
                          ),
                        ),
                        istrue==0?Visibility(child:  Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Text(AppLocalizations().lbCpassMatch,style: TextStyle(color: Colors.red),),
                        ),visible: false,):
                        Visibility(child:  Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Row(children: <Widget>[Text(AppLocalizations().lbCpassMatch,style: TextStyle(color: Colors.red),)],),
                        ),visible: true,),
                       Padding(
                          padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                          child: Center(
                            child: RaisedButton(
                              onPressed:  () {
                                /*  Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => addpassword(),
                                  ),
                                );*/
                                _buildSubmitForm(context);
                              },
                              disabledColor: Colors.praimarydark,
                              color:Colors.praimarydark ,
                              child: Text(
                                AppLocalizations().lbSubmit,
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  _buildSubmitForm(BuildContext context) async {
    // String workingTime;
    isold=0;
    istrue=0;
    if(old.toString()==oldPass.text.toString()){
      if(newPass.text.toString()!=ConfirmNew.text.toString()){
        setState(() {
          istrue = 1;
        });
      }
      else{
        pr.show();

        var preferences = await SharedPreferences.getInstance();
        sessionId = preferences.getString('sessionId');
        email = preferences.getString('emailp');
        phaN = preferences.getString('pharman');
        phacN = preferences.getString('pharmasi');
        long = preferences.getString('long');
        lat = preferences.getString('lat');
        cityId = preferences.getString('cityn');
        address = preferences.getString('adress');
        licNum = preferences.getString('licnum');
        status = preferences.getString('statusu');
        woH = preferences.getString('workhour');
        synNum = preferences.getString('SyndicateNumber');
        PharmPic = preferences.getString('PharmacyPhoto');
        SynPic = preferences.getString('SyndicateIdPhoto');

        Map<String, dynamic> data = {






          "Email": email.toString(),
          "Password": newPass.text,
          "PharmacyName": phaN.toString(),
          "PharmacistName": phacN.toString(),
          "Address": address,
          "Longitude": long,
          "Latidute": lat,
          "LicenseNumber":licNum,
          "Status":status=="null"?
          null:
          status,
          "CityId": cityId,
          "WorkingHours": woH,
          "SyndicateNumber":synNum,
          "PharmacyPhoto": PharmPic,
          "SyndicateIdPhoto": SynPic




        };
        print(data);

        final CityRepository _repository = CityRepository();

        registerResponse response = await _repository.changePass(sessionId,data,langSave);

        if (response.code == '1') {
          pr.hide().then((isHidden) {
            print(isHidden);
          });
          preferences.remove('sessionId');

          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>Directionality(
                textDirection:
                langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: Splash()),
            ),
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
    }else{
      setState(() {
        isold=1;
      });
    }

  }


}
