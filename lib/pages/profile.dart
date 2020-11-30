import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmas/Bloc/blocHome.dart';
import 'package:pharmas/Model/loginModel.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/loginResponse.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/Durgs/durgsList.dart';
import 'package:pharmas/pages/Pharma/PharmaListPage.dart';
import 'package:pharmas/pages/homePage.dart';
import 'package:pharmas/pages/register.dart';
import 'package:pharmas/pages/verifyCode.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'forgetPassword.dart';

class profile extends StatefulWidget {
  @override
  _profile createState() => new _profile();
}

class _profile extends State<profile> {
  var preferences;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String sessionId;
  String email,phaN,phacN,address,long,lat,licNum,status,cityId,woH,synNum,workH,PharmPic,SynPic;
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

  List<User> userList;
String lati,loni;
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
    navigationPageL();
    navigationPage();
  }

  Future navigationPage() async {

    preferences = await SharedPreferences.getInstance();
    sessionId = preferences.getString('sessionId');
    lati = preferences.getString('lat');
    loni = preferences.getString('long');


    blocHome.getMyPro(sessionId,langSave);

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[

            GestureDetector(child: Visibility(child: Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0),child: Icon(
              Icons.edit,
              color: Colors.white,
            ),),visible: true,),
              onTap: (){

                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        mapEdit(lati,loni, this),
                  ),
                );


              },)
          ],
          title: Text(
            AppLocalizations().lbMyPro,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.praimarydark,
        ),
        resizeToAvoidBottomPadding: true,
        body:StreamBuilder(
          stream: blocHome.subjectPro.stream,
          builder:
              (BuildContext context, AsyncSnapshot<loginResponse> snapshot) {
            if (snapshot.hasData) {
              /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

              return new  ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset('assets/images/pharmap.png'),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                            child: Text(
                                              snapshot.data.data.PharmacyName,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset('assets/images/pharname.png'),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                            child: Text(AppLocalizations().lbDr+  snapshot.data.data.PharmacistName,
                                              style: TextStyle(fontSize: 17),),
                                          )
                                        ],
                                      ),
                                    ),
                              snapshot.data.data.phone=="null"?Visibility(child:Padding(
                                padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.phone,color: Colors.praimarydark,),
                                    Padding(
                                      padding:
                                      EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Text(snapshot.data.data.phone==null?'0':snapshot.data.data.phone,
                                        style: TextStyle(fontSize: 17),),
                                    )
                                  ],
                                ),
                              ), visible: false,):
                                  Visibility(child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.phone,color: Colors.praimarydark,),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(15, 0, 15, 0),
                                          child: Text(snapshot.data.data.phone==null?'0':snapshot.data.data.phone,
                                            style: TextStyle(fontSize: 17),),
                                        )
                                      ],
                                    ),
                                  ),visible: true,),
                                    snapshot.data.data.mobile=="null"?Visibility(child: Padding(
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.mobile_screen_share,color: Colors.praimarydark,),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                            child: Text( snapshot.data.data.mobile==null?'0':snapshot.data.data.mobile,
                                              style: TextStyle(fontSize: 17),),
                                          )
                                        ],
                                      ),
                                    ),visible: false,):
                                        Visibility(child: Padding(
                                          padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.mobile_screen_share,color: Colors.praimarydark,),
                                              Padding(
                                                padding:
                                                EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                child: Text( snapshot.data.data.mobile==null?'0':snapshot.data.data.mobile,
                                                  style: TextStyle(fontSize: 17),),
                                              )
                                            ],
                                          ),
                                        ),visible:true)
                                    ,




                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset('assets/images/liclogo.png'),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                            child: Text( snapshot.data.data.LicenseNumber,style: TextStyle(fontSize: 17),),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset('assets/images/emaillogo.png'),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                            child: Text( snapshot.data.data.email,style: TextStyle(fontSize: 17),),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset('assets/images/location.png'),
                                          Padding(
                                            padding:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                            child: Text( snapshot.data.data.City + '-' +  snapshot.data.data.Address,style: TextStyle(fontSize: 17),),
                                          ),
                                          new Spacer(),
                                          GestureDetector(child: Image.asset('assets/images/mappharma.png'),onTap: (){
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    map(snapshot.data.data.Latidute, snapshot.data.data.Longitude),
                                              ),
                                            );
                                          },),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text('error');
            } else {
              return Center(child: CircularProgressIndicator(
                  valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),);
            }
          },
        )



       );
  }


  _buildSubmitForm(String lann,String lonn) async {
    // String workingTime;



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
    "Password": "",
    "PharmacyName": phaN.toString(),
    "PharmacistName": phacN.toString(),
    "Address": address,
    "Longitude": lonn,
    "Latidute": lann,
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

      navigationPage();
    } else {
      Toast.show(
          response.msg.toString(),
          context,
          duration: 4,
          gravity: Toast.BOTTOM);
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
          position: LatLng(double.parse(widget.lat),double.parse(widget.lon)),
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
                  target: LatLng(double.parse(widget.lat),double.parse(widget.lon)),
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




class mapEdit extends StatefulWidget {
  final String lat;

  final String lon;
  final _profile reg;

  mapEdit(this.lat, this.lon,this.reg);

  @override
  _mapEdit createState() => new _mapEdit();
}

class _mapEdit extends State<mapEdit> {
  GoogleMapController mapController;

  String lat;

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
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              markers: markers,
              initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(widget.lat), double.parse(widget.lon)),
                  zoom: 15.0),
              mapType: MapType.normal,
              onTap: (position) {
                Marker mk1 = Marker(
                  infoWindow: InfoWindow(
                      title: position.latitude.toString() +
                          ',' +
                          position.longitude.toString()),
                  markerId: MarkerId('1'),
                  position: position,
                );

                setState(() {
                  markers.clear();
                  markers.add(mk1);
                  saveValue(position.latitude.toString(),
                      position.longitude.toString());

// Save a value
                  // Navigator.of(context).pop();

                  print(position.latitude.toString());
                });
              },
              onMapCreated: _onMapCreated,
              /* onMapCreated: (GoogleMapController controller) {

                _controller.complete(controller);

              },
*/
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: FloatingActionButton.extended(
                  icon: Icon(Icons.location_on),
                  label: Text(AppLocalizations().lbDone),
                  onPressed: () {
                    saveValuede(double.parse(widget.lat).toString(), double.parse(widget.lon).toString());
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  saveValue(String lat, String lon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lat', lat);

    prefs.setString('lon', lon);

    widget.reg.setState(() {
      widget.reg._buildSubmitForm(lat,lon);
      widget.reg.initState();
    });
  }

  saveValuede(String lat, String lon) async {
    var preferences = await SharedPreferences.getInstance();
    String latdefault = preferences.getString('lat');
    String londe = preferences.getString('lon');

    if (latdefault == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lat', widget.lat.toString());

      prefs.setString('lon', widget.lon.toString());
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lat', latdefault);

      prefs.setString('lon', londe);
    }

    widget.reg.setState(() {
      widget.reg._buildSubmitForm(latdefault,londe);

      widget.reg.initState();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Polyline> poly = {};
}