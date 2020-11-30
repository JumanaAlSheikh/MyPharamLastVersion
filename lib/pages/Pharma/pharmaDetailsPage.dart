import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pharmas/Model/pharmaListModel.dart';
import 'package:pharmas/lang/localss.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pharmaDeails extends StatefulWidget {
  final pharmasAllList pharmaItem;

  pharmaDeails(this.pharmaItem);

  @override
  _pharmaDeails createState() => new _pharmaDeails();
}

class _pharmaDeails extends State<pharmaDeails> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
    // getValueString();
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
    print(widget.pharmaItem.WorkingHours);

    navigationPage();
    //  navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pharmaItem.PharmacyName,
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
      resizeToAvoidBottomPadding: true,
      body: ListView(
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
                                  Image.asset(
                                    'assets/images/pharname.png',
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    child: Text(
                                      AppLocalizations().lbDr + widget.pharmaItem.PharmacistName,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: <Widget>[
                                Row(children: <Widget>[
                                  Image.asset(
                                    'assets/images/location.png',
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    child: Text(
                                      widget.pharmaItem.City + ' - ' + widget.pharmaItem.Address,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),],),new Spacer(),
                                  GestureDetector(child: Image.asset(
                                    'assets/images/mappharma.png',

                                  ),onTap: (){
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            map( widget.pharmaItem.Latidute,  widget.pharmaItem.Longitude),
                                      ),
                                    );
                                  },),
                                ],
                              ),
                            ),
                            widget.pharmaItem.Phone=="null"?Visibility(child:  GestureDetector(onTap: (){
                              _initiateCallPhone( widget.pharmaItem.Phone);

                            },child:    Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone,color: Colors.praimarydark,),

                                  Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Text(  widget.pharmaItem.Phone,style: TextStyle(color: Colors.grey))
                                  )
                                ],
                              ),
                            ),),visible: false,):
                            Visibility(child: GestureDetector(onTap: (){
                              _initiateCallPhone( widget.pharmaItem.Phone);

                            },child:    Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone,color: Colors.praimarydark,),

                                  Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Text(  widget.pharmaItem.Phone,style: TextStyle(color: Colors.grey))
                                  )
                                ],
                              ),
                            ),),visible: true,),



                            widget.pharmaItem.Mobile=="null"?Visibility(child: GestureDetector(onTap: (){
                              _initiateCallMobile( widget.pharmaItem.Mobile);

                            },child:  Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone_android,color: Colors.praimarydark,),

                                  Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Text(  widget.pharmaItem.Mobile,style: TextStyle(color: Colors.grey))
                                  )
                                ],
                              ),
                            ),),visible: false,):
                            Visibility(child: GestureDetector(onTap: (){
                              _initiateCallMobile( widget.pharmaItem.Mobile);

                            },child:  Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone_android,color: Colors.praimarydark,),

                                  Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Text(  widget.pharmaItem.Mobile,style: TextStyle(color: Colors.grey))
                                  )
                                ],
                              ),
                            ),),visible: true,),


                            Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 10),child: Divider(
                              height: 1,
                              color: Colors.grey,
                            ),),
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                   AppLocalizations().lbWh+' :',
                                    style: TextStyle(
                                      color: Colors.praimarydark,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 2, 0, 3),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        widget.pharmaItem.WorkingHours
                                            .toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )),
                           
                           
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
      ),
    );
  }

  _initiateCallPhone(String _phoneNumber) {
    if (_phoneNumber?.isNotEmpty == true) {
      setState(() {
        FlutterPhoneState.startPhoneCall(_phoneNumber);
      });
    }
  }
  _initiateCallMobile(String _phoneNumber) {
    if (_phoneNumber?.isNotEmpty == true) {
      setState(() {
        FlutterPhoneState.startPhoneCall(_phoneNumber);
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