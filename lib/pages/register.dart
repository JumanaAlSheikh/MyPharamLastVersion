import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:location/location.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:toast/toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:mime/mime.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:pharmas/pages/verifyCode.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:path/path.dart';

import 'package:dio/dio.dart';

class register extends StatefulWidget {
  final String latu;
  final String lonu;

  register(this.latu, this.lonu);

  @override
  _register createState() => new _register();
}

class _register extends State<register> {
  final _email = TextEditingController();
  File _imageFileSy;
  File _imageFilePh;
  String chch , cityname;
  String idcity;

  ProgressDialog pr;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
//  Location _location = new Location();
  final _phone = TextEditingController();
  final _mobile = TextEditingController();
  final _synnum = TextEditingController();
  bool pressed = false;
  bool loading = false;
  bool loading_map = false;
  bool get_location = false;
  String PharmacyPhoto, SYNPhoto;
  final _password = TextEditingController();
  final _confirmpass = TextEditingController();
  final _pharmacistName = TextEditingController();
  final _pharmaName = TextEditingController();
  final _lesenceNumber = TextEditingController();
  String fromTime, toTime;
  final _address = TextEditingController();
  var todate = GlobalKey<FormState>();
  String baseUrl = 'http://mypharma-order.com/api/upload.php';
  bool askingPermission = false;

  var fromdate = GlobalKey<FormState>();
  GoogleMapController mapController;
  geo.Position res;
  bool _isUploading = false;
  bool _isUploadingPh = false;

  String lat = '0';
  String lon = '0';
  List<City> citylist = new List<City>();
  City newlistc;
  intl.DateFormat format = intl.DateFormat("HH:mm");

  getValueString() async {
    var preferences = await SharedPreferences.getInstance();
    lat = preferences.getString('lat');
    lon = preferences.getString('lon');
  }
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
    initializeDateFormatting();
    format = intl.DateFormat("HH:mm");
    navigationPage();

    pr = new ProgressDialog(this.context);
    pr.update(
      progress: 50.0,
      message: AppLocalizations().lbWait,
      progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.praimarydark))),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    blocCity.getCity(langSave);
    getValueString();
    //  navigationPage();
    getLocationPermission();
    getCurrentLocation();
  }

  Future<bool> getLocationPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {}
    }

    _locationData = await location.getLocation();
    print(_locationData);
    setState(() {
      res = geo.Position(
          latitude: _locationData.latitude, longitude: _locationData.longitude);
    });
  }

  Future<void> getCurrentLocation() async {
    geo.Position posiion = await geo.Geolocator()
        .getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);
    setState(() {
      res = posiion;
      //    _createMarker();
      //  markers = _createMarker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      body: StreamBuilder(
        stream: blocCity.subject.stream,
        builder: (BuildContext context, AsyncSnapshot<CityResponse> snapshot) {
          if (snapshot.hasData) {
            /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

            citylist = snapshot.data.results.citiesr.cities;
            City dfvdfg ;
            newlistc=citylist[0];
            if(newlistc.id==-1){
              citylist.removeWhere((element) => element == newlistc);
            }


            //   dynamic res = citylist.removeAt(0);
            return new ListView(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    // height: MediaQuery.of(context).size.height,
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
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Image.asset(
                                          'assets/images/nextleft.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(
                                          AppLocalizations().lbReg,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.praimarydark),
                                      textAlign: TextAlign.center,
                                    ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _email,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbEmail,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _password,
                                  cursorColor: Colors.praimarydark,
                                  obscureText: true,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbPass,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _confirmpass,
                                  cursorColor: Colors.praimarydark,
                                  obscureText: true,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbCpass,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _pharmacistName,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbPhasN,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _pharmaName,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbPhacN,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 0),
                                child: TextField(maxLength: 10,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  controller: _phone,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbPhone+" :"+AppLocalizations().lbEx +"011 111 1111",
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: TextField(maxLength: 10,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  controller: _mobile,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbMobile+" :"+AppLocalizations().lbEx +"0999 999 999",

                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
                                child: TextField(
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  controller: _synnum,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbSyNum,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  controller: _lesenceNumber,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbLisNum,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),





                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _address,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbAddress,
                                    hintStyle:
                                        TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child:   Padding(
                                  padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                                  child:   chch == null
                                      ?
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
                                          AppLocalizations().lbSelectc,style: TextStyle(color: Colors.praimarydark),),
                                        new Spacer(),
                                        Icon(Icons.keyboard_arrow_down,color:Colors.praimarydark)
                                      ],
                                    ),
                                  ):

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
                                          '$chch',style: TextStyle(color: Colors.praimarydark),),
                                        new Spacer(),
                                        Icon(Icons.keyboard_arrow_down,color:Colors.praimarydark)
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  displayBottomSheet(
                                      context, citylist);


                                },),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Divider(height: 1,color: Colors.praimarydark,),),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 5, 10, 5),
                                        child: Column(
                                          children: <Widget>[
                                            lat == null
                                                ? Text(
                                                    AppLocalizations().lbLoccation,
                                                    style: TextStyle(
                                                        color:
                                                            Colors.praimarydark,
                                                        fontSize: 16),
                                                  )
                                                : Container(child: Text(
                                              '$lat' + ' , ' + '$lon',
                                              style: TextStyle(
                                                  color:
                                                  Colors.praimarydark,
                                                  fontSize: 16),
                                            ),width:130),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                          child: Image.asset(
                                            'assets/images/location.png',
                                          ),
                                          onTap: () {
                                            //final PermissionStatus permission = await PermissionHandler()
                                            //  .checkPermissionStatus(PermissionGroup.location);
                                            //   LocationPermissions().openAppSettings().then((bool hasOpened) =>
                                            //     debugPrint('App Settings opened: ' + hasOpened.toString()));
                                            getCurrentLocation();
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    map(res, this),
                                              ),
                                            );
                                          }),
                                    ],
                                  )),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Divider(
                                  height: 2,
                                  color: Colors.praimarydark,
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 25, 30, 5),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          AppLocalizations().lbWh+' :',
                                          style: TextStyle(
                                              color: Colors.praimarydark),
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 150,
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Form(
                                            key: fromdate,
                                            child: DateTimeField(
                                              validator: (val) {
                                                if (val != null) {
                                                  return null;
                                                } else {
                                                  return AppLocalizations().lbFrom;
                                                }
                                              },
                                              onSaved: (value) {
                                                fromTime = value.toString().substring(11,19);

                                              },

                                              format: format,
                                              decoration: new InputDecoration(
                                                  hintText: AppLocalizations().lbFrom),
                                              style: TextStyle(
                                                  color: Colors.praimarydark),
                                              onShowPicker: (context,
                                                  currentValue) async {
                                                final time =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      TimeOfDay.fromDateTime(
                                                          currentValue ??
                                                              DateTime.now()),
                                                );
                                                return DateTimeField.convert(
                                                    time);
                                              },
                                            )),
                                      ),
                                      Container(
                                        width: 150,
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Form(
                                          key: todate,
                                          child: DateTimeField(
                                            format: format,
                                            validator: (val) {
                                              if (val != null) {
                                                return null;
                                              } else {
                                                return AppLocalizations().lbTo;
                                              }
                                            },
                                            onSaved: (value) {
                                              toTime = value.toString().substring(11,19);

                                            },
                                            decoration: new InputDecoration(
                                                hintText: AppLocalizations().lbTo),
                                            style: TextStyle(
                                                color: Colors.praimarydark),
                                            onShowPicker:
                                                (context, currentValue) async {
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    TimeOfDay.fromDateTime(
                                                        currentValue ??
                                                            DateTime.now()),
                                              );
                                              return DateTimeField.convert(
                                                  time);
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          AppLocalizations().lbPhotoSyn+' :',
                                          style: TextStyle(
                                              color: Colors.praimarydark),
                                        ),
                                      ),
                                    ],
                                  )),
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    child: OutlineButton(
                                      onPressed: () =>
                                          _openImagePickerModal(context),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.camera_alt),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(AppLocalizations().lbAddI),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _imageFileSy == null
                                      ? Text(AppLocalizations().lbAddIP)
                                      : Column(
                                          children: <Widget>[
                                            GestureDetector(
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.cancel,
                                                    color: Colors.praimarydark,
                                                  )
                                                ],
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _imageFileSy = null;
                                                });
                                              },
                                            ),
                                            Padding(
                                              child: Image.file(
                                                _imageFileSy,
                                                fit: BoxFit.cover,
                                                height: 300.0,
                                                alignment: Alignment.topCenter,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 5, 0, 5),
                                            )
                                          ],
                                        ),
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          AppLocalizations().lbPhotoPh+' : ',
                                          style: TextStyle(
                                              color: Colors.praimarydark),
                                        ),
                                      ),
                                    ],
                                  )),
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    child: OutlineButton(
                                      onPressed: () =>
                                          _openImagePickerModalPh(context),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.camera_alt),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(AppLocalizations().lbAddI),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _imageFilePh == null
                                      ? Text(AppLocalizations().lbAddIP)
                                      : Column(
                                          children: <Widget>[
                                            GestureDetector(
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.cancel,
                                                    color: Colors.praimarydark,
                                                  )
                                                ],
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _imageFilePh = null;
                                                });
                                              },
                                            ),
                                            Padding(
                                              child: Image.file(
                                                _imageFilePh,
                                                fit: BoxFit.cover,
                                                height: 300.0,
                                                alignment: Alignment.topCenter,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 5, 0, 5),
                                            )
                                          ],
                                        )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
                                child: Center(
                                  child: RaisedButton(
                                    onPressed: () {
                                      _buildSubmitForm(context);
                                      /* Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              verifyCode(),
                                        ),
                                      );*/
                                    },
                                    disabledColor: Colors.praimarydark,
                                    color: Colors.praimarydark,
                                    child: Text(
                                      AppLocalizations().lbSubmit,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
              shrinkWrap: true,
            );
          } else if (snapshot.hasError) {
            return Text('error');
          } else {
            return new ListView(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    // height: MediaQuery.of(context).size.height,
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
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Image.asset(
                                          'assets/images/nextleft.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(
                                          AppLocalizations().lbReg,
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.praimarydark),
                                          textAlign: TextAlign.center,
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _email,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbEmail,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _password,
                                  cursorColor: Colors.praimarydark,
                                  obscureText: true,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbPass,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _confirmpass,
                                  cursorColor: Colors.praimarydark,
                                  obscureText: true,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbCpass,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _pharmacistName,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbPhasN,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _pharmaName,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText:  AppLocalizations().lbPhacN,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 0),
                                child: TextField(maxLength: 10,
                                  keyboardType:
                                  TextInputType.numberWithOptions(),
                                  controller: _phone,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbPhone+' :'+AppLocalizations().lbEx +'011 111 1111',
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: TextField(maxLength: 10,
                                  keyboardType:
                                  TextInputType.numberWithOptions(),
                                  controller: _mobile,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbMobile+' :'+AppLocalizations().lbEx +'0999 999 999',

                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
                                child: TextField(
                                  keyboardType:
                                  TextInputType.numberWithOptions(),
                                  controller: _synnum,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbSyNum,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  keyboardType:
                                  TextInputType.numberWithOptions(),
                                  controller: _lesenceNumber,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbLisNum,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),





                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: TextField(
                                  controller: _address,
                                  cursorColor: Colors.praimarydark,
                                  style: TextStyle(color: Colors.praimarydark),
                                  decoration: InputDecoration(
                                    filled: true,

                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations().lbAddress,
                                    hintStyle:
                                    TextStyle(color: Colors.praimarydark),
                                    //can also add icon to the end of the textfiled
                                    //  suffixIcon: Icon(Icons.remove_red_eye),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child:   Padding(
                                  padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                                  child:   chch == null
                                      ?
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
                                          AppLocalizations().lbSelectc,style: TextStyle(color: Colors.praimarydark),),
                                        new Spacer(),
                                        Icon(Icons.keyboard_arrow_down,color:Colors.praimarydark)
                                      ],
                                    ),
                                  ):

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
                                          '$chch',style: TextStyle(color: Colors.praimarydark),),
                                        new Spacer(),
                                        Icon(Icons.keyboard_arrow_down,color:Colors.praimarydark)
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  displayBottomSheet(
                                      context, citylist);


                                },),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Divider(height: 1,color: Colors.praimarydark,),),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(10, 5, 10, 5),
                                        child: Column(
                                          children: <Widget>[
                                            lat == null
                                                ? Text(
                                              AppLocalizations().lbLoccation,
                                              style: TextStyle(
                                                  color:
                                                  Colors.praimarydark,
                                                  fontSize: 16),
                                            )
                                                : Container(child: Text(
                                              '$lat' + ' , ' + '$lon',
                                              style: TextStyle(
                                                  color:
                                                  Colors.praimarydark,
                                                  fontSize: 16),
                                            ),width:130),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                          child: Image.asset(
                                            'assets/images/location.png',
                                          ),
                                          onTap: () {
                                            //final PermissionStatus permission = await PermissionHandler()
                                            //  .checkPermissionStatus(PermissionGroup.location);
                                            //   LocationPermissions().openAppSettings().then((bool hasOpened) =>
                                            //     debugPrint('App Settings opened: ' + hasOpened.toString()));
                                            getCurrentLocation();
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    map(res, this),
                                              ),
                                            );
                                          }),
                                    ],
                                  )),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Divider(
                                  height: 2,
                                  color: Colors.praimarydark,
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 25, 30, 5),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          AppLocalizations().lbWh+' :',
                                          style: TextStyle(
                                              color: Colors.praimarydark),
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 150,
                                        padding:
                                        EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Form(
                                            key: fromdate,
                                            child: DateTimeField(
                                              validator: (val) {
                                                if (val != null) {
                                                  return null;
                                                } else {
                                                  return AppLocalizations().lbFrom;
                                                }
                                              },
                                              onSaved: (value) {
                                                fromTime = value.toString().substring(11,19);

                                              },
                                              format: format,
                                              decoration: new InputDecoration(
                                                  hintText: AppLocalizations().lbFrom),
                                              style: TextStyle(
                                                  color: Colors.praimarydark),
                                              onShowPicker: (context,
                                                  currentValue) async {
                                                final time =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                  TimeOfDay.fromDateTime(
                                                      currentValue ??
                                                          DateTime.now()),
                                                );
                                                return DateTimeField.convert(
                                                    time);
                                              },
                                            )),
                                      ),
                                      Container(
                                        width: 150,
                                        padding:
                                        EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Form(
                                          key: todate,
                                          child: DateTimeField(
                                            format: format,
                                            validator: (val) {
                                              if (val != null) {
                                                return null;
                                              } else {
                                                return AppLocalizations().lbTo;
                                              }
                                            },
                                            onSaved: (value) {
                                              toTime = value.toString().substring(11,19);

                                            },
                                            decoration: new InputDecoration(
                                                hintText: AppLocalizations().lbTo),
                                            style: TextStyle(
                                                color: Colors.praimarydark),
                                            onShowPicker:
                                                (context, currentValue) async {
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime:
                                                TimeOfDay.fromDateTime(
                                                    currentValue ??
                                                        DateTime.now()),
                                              );
                                              return DateTimeField.convert(
                                                  time);
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          AppLocalizations().lbPhotoSyn+' :',
                                          style: TextStyle(
                                              color: Colors.praimarydark),
                                        ),
                                      ),
                                    ],
                                  )),
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    child: OutlineButton(
                                      onPressed: () =>
                                          _openImagePickerModal(context),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.camera_alt),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text( AppLocalizations().lbAddI),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _imageFileSy == null
                                      ? Text( AppLocalizations().lbAddIP)
                                      : Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.praimarydark,
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _imageFileSy = null;
                                          });
                                        },
                                      ),
                                      Padding(
                                        child: Image.file(
                                          _imageFileSy,
                                          fit: BoxFit.cover,
                                          height: 300.0,
                                          alignment: Alignment.topCenter,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                            0, 5, 0, 5),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text(
                                          AppLocalizations().lbPhotoPh+' : ',
                                          style: TextStyle(
                                              color: Colors.praimarydark),
                                        ),
                                      ),
                                    ],
                                  )),
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    child: OutlineButton(
                                      onPressed: () =>
                                          _openImagePickerModalPh(context),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.camera_alt),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(AppLocalizations().lbAddI),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _imageFilePh == null
                                      ? Text(AppLocalizations().lbAddIP)
                                      : Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.praimarydark,
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _imageFilePh = null;
                                          });
                                        },
                                      ),
                                      Padding(
                                        child: Image.file(
                                          _imageFilePh,
                                          fit: BoxFit.cover,
                                          height: 300.0,
                                          alignment: Alignment.topCenter,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                            0, 5, 0, 5),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
                                child: Center(
                                  child: RaisedButton(
                                    onPressed: () {
                                      _buildSubmitForm(context);
                                      /* Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              verifyCode(),
                                        ),
                                      );*/
                                    },
                                    disabledColor: Colors.praimarydark,
                                    color: Colors.praimarydark,
                                    child: Text(
                                      AppLocalizations().lbSubmit,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
              shrinkWrap: true,
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _uploadImage(File image) async {
    pr.show();
    setState(() {
      _isUploading = true;
    });
    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));
    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    imageUploadRequest.fields
        .addAll({'type': 'pharmacies', 'action': 'upload_image'});
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic> nameph = responseData['data'];
      PharmacyPhoto = nameph['file_name'].toString();
      //  _resetState();
    //  _startUploadingPh(this.context);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> _uploadImagePh(File image) async {
    pr.show();
    setState(() {
      _isUploadingPh = true;
    });
    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));
    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    imageUploadRequest.fields
        .addAll({'type': 'pharmacies', 'action': 'upload_image'});
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        return null;
      }


      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic> nameph = responseData['data'];
      SYNPhoto = nameph['file_name'].toString();
      //  _resetStatePh();
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _resetState() {
    setState(() {
      _isUploading = false;
      _imageFileSy = null;
    });
  }

  void _resetStatePh() {
    setState(() {
      _isUploadingPh = false;
      _imageFilePh = null;
    });
  }

  void _startUploading(BuildContext context) async {
    final Map<String, dynamic> response = await _uploadImage(_imageFileSy);
    print(response);
    // Check if any error occured
    if (response == null || response.containsKey("error")) {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Toast.show(AppLocalizations().lbUpIF, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show(AppLocalizations().lbUpIS, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _startUploadingPh(BuildContext context) async {
    final Map<String, dynamic> response = await _uploadImagePh(_imageFilePh);
    print(response);
    // Check if any error occured
    if (response == null || response.containsKey("error")) {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Toast.show(AppLocalizations().lbUpIF, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show(AppLocalizations().lbUpIS, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  _buildSubmitForm(BuildContext context) async {

    print('011'+_phone.text);
    if (_imageFileSy == null) {
      Toast.show(AppLocalizations().lbSyPS, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_imageFilePh == null) {
      Toast.show(AppLocalizations().lbPhPS, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      pr.show();
      _buildSubmitFormDone(context);
    }
  }

  _buildSubmitFormDone(BuildContext context) async {
    String workingTime;
    pr.show();

    if (todate.currentState.validate()) {
      // fromdate.currentState.save();
      todate.currentState.save();
    }
    if (fromdate.currentState.validate()) {
      // fromdate.currentState.save();
      fromdate.currentState.save();
      workingTime = fromTime + ', ' + toTime;
    }

    Map<String, dynamic> data = {
      "Email": _email.text,
      "Password": _password.text,
      "PharmacyName": _pharmaName.text,
      "PharmacistName": _pharmacistName.text,
      "Address": _address.text,
      "Longitude": lon,
      "Latidute": lat,
      "LicenseNumber": _lesenceNumber.text,
      "CityId":idcity,
      "WorkingHours": workingTime,
      "SyndicateNumber": _synnum.text,
      "PharmacyPhoto": PharmacyPhoto,
      "SyndicateIdPhoto": SYNPhoto,
      "Phone": _phone.text,
      "Mobile": _mobile.text
    };
print(data);
    final CityRepository _repository = CityRepository();

    registerResponse response = await _repository.register(data,langSave);

    if (response.code == '1') {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => Directionality(
              textDirection:
              langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: verifyCode(_email.text)),
        ),
      );
    } else {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Toast.show(response.msg.toString(), context,
          duration: 4, gravity: Toast.BOTTOM);
    }
  }

  void _openImagePickerModal(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  AppLocalizations().lbPickI,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text(AppLocalizations().lbCamera),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text(AppLocalizations().lbGallery),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _getImage(BuildContext context, ImageSource source) async {

    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFileSy = image;

    });
    // Closes the bottom sheet    _startUploading(context);
    _startUploading(context);

    Navigator.pop(context);
  }

  void _openImagePickerModalPh(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  AppLocalizations().lbPickI,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text(AppLocalizations().lbCamera),
                  onPressed: () {
                    _getImagePh(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text(AppLocalizations().lbGallery),
                  onPressed: () {
                    _getImagePh(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _getImagePh(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFilePh = image;
    });
    // Closes the bottom sheet
    _startUploadingPh(context);

    Navigator.pop(context);
  }

  void displayBottomSheet(BuildContext context, List<City> citiee) {
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
                        citiee[index].check = true;
                        chch = citiee[index].cityName;
                        idcity = citiee[index].id.toString();
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }),
          );
        });
  }





}

class map extends StatefulWidget {
  final geo.Position pos;

  final _register reg;

  map(this.pos, this.reg);

  @override
  _map createState() => new _map();
}

class _map extends State<map> {
  GoogleMapController mapController;

  String lat;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers;

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId(AppLocalizations().lbLoccation),
          position: LatLng(widget.pos.latitude, widget.pos.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: AppLocalizations().lbLoccation))
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
                  target: LatLng(widget.pos.latitude, widget.pos.longitude),
                  zoom: 10.0),
              mapType: MapType.normal,
              mapToolbarEnabled: false,
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
                    saveValuede(widget.pos.latitude.toString(),
                        widget.pos.longitude.toString());
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
      widget.reg.initState();
    });
  }

  saveValuede(String lat, String lon) async {
    var preferences = await SharedPreferences.getInstance();
    String latdefault = preferences.getString('lat');
    String londe = preferences.getString('lon');

    if (latdefault == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lat', widget.pos.latitude.toString());

      prefs.setString('lon', widget.pos.longitude.toString());
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lat', latdefault);

      prefs.setString('lon', londe);
    }

    widget.reg.setState(() {
      widget.reg.initState();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Polyline> poly = {};
}
