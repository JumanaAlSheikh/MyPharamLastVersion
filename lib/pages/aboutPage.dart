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


class aboutP extends StatefulWidget {
  @override
  _aboutP createState() => new _aboutP();
}

class _aboutP extends State<aboutP> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
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
    navigationPageL();
    navigationPage();

    //  navigationPage();

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
      title: Text(AppLocalizations().lbAbout),

    ),
      body: Container(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Text('المنشأ المهندس عامر قصيباتي \n للتواصل 0966664584',
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ),

                    ],
                  ),
                  alignment: Alignment.center,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }




}
