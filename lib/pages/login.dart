import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/loginResponse.dart';
import 'package:pharmas/pages/Durgs/durgsList.dart';
import 'package:pharmas/pages/Pharma/PharmaListPage.dart';
import 'package:pharmas/pages/homePage.dart';
import 'package:pharmas/pages/register.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:toast/toast.dart';

import 'package:pharmas/pages/verifyCode.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmas/lang/localss.dart';

import 'forgetPassword.dart';

class login extends StatefulWidget {
  @override
  _login createState() => new _login();
}

class _login extends State<login> {
  String lat, lon;
  String msgError;

  // To track the file uploading state
  bool _isUploading = false;

  final _email = TextEditingController();
  final _password = TextEditingController();
  ProgressDialog pr;
  String _response = '';
  bool _apiCall = false;
  String baseUrl = 'https://saydaliti2.000webhostapp.com/api/upload.php';
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

  @override
  void initState() {
    initializeDateFormatting();

    navigationPage();
    pr = new ProgressDialog(context);
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
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/images/registration.jpg'),
          fit: BoxFit.fill,
        )),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 70, 0, 30),
                  child: Text(
                    AppLocalizations().lbLogin,
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.praimarydark),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 70, 30, 10),
                  child: TextField(
                    controller: _email,
                    cursorColor: Colors.praimarydark,
                    style: TextStyle(color: Colors.praimarydark),
                    decoration: InputDecoration(
                      filled: true,

                      fillColor: Colors.transparent,
                      hintText: AppLocalizations().lbEmail,
                      hintStyle: TextStyle(color: Colors.praimarydark),
                      //can also add icon to the end of the textfiled
                      //  suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: TextField(
                    controller: _password,
                    cursorColor: Colors.praimarydark,
                    obscureText: true,
                    style: TextStyle(color: Colors.praimarydark),
                    decoration: InputDecoration(
                      filled: true,

                      fillColor: Colors.transparent,
                      hintText: AppLocalizations().lbPass,
                      hintStyle: TextStyle(color: Colors.praimarydark),
                      //can also add icon to the end of the textfiled
                      //  suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                  ),
                ),

                msgError==null?Visibility(child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child:Text('$msgError',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                ),visible: false,):Visibility(child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child:Text('$msgError',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                ),visible: true,),



                Padding(
                  padding: EdgeInsets.fromLTRB(115, 80, 115, 50),
                  child: GestureDetector(
                      onTap: () {
                        _buildSubmitForm(context);
                      },
                      child: Container(
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
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.praimary, width: 1))),
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Colors.praimary, width: 1))),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      Directionality(
                                          textDirection:
                                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                          child:  register(lat, lon)
                                      )
                                ),
                              );
                            },
                            child: Text(AppLocalizations().lbReg,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Colors.praimary, width: 1))),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      Directionality(
                                          textDirection:
                                          langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                          child:  forget()
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations().lbFor,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    ));
  }

  Future<loginResponse> apiRequest(String url, Map map) async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    HttpClientRequest request = await client.postUrl(Uri.parse(url));

    request.headers.set('content-type', 'application/json');

    request.add(utf8.encode(json.encode(map)));

    HttpClientResponse response = await request.close();

    String reply = await response.transform(utf8.decoder).join();

    print(reply);

    // todo - you should check the response.statusCode
    // httpClient.close();
    loginResponse res = loginResponse.fromJson(json.decode(reply));

    if (res.code == "1") {
      pr.hide().then((isHidden) {
        print(isHidden);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('sessionId', res.data.sessionId.toString());
      prefs.setString('emailp', res.data.email.toString());
      prefs.setString('pharman', res.data.PharmacyName.toString());
      prefs.setString('pharmasi', res.data.PharmacistName.toString());
      prefs.setString('long', res.data.Longitude.toString());
      prefs.setString('lat', res.data.Latidute.toString());
      prefs.setString('cityn', res.data.cityId.toString());
      prefs.setString('cityname', res.data.City.toString());

      prefs.setString('adress', res.data.Address.toString());
      prefs.setString('licnum', res.data.LicenseNumber.toString());
      prefs.setString('statusu', res.data.Status.toString());
      prefs.setString('workhour', res.data.WorkingHours.toString());
      prefs.setString('SyndicateNumber', res.data.SynNum.toString());
      prefs.setString('PharmacyPhoto', res.data.pharmaPic.toString());
      prefs.setString('SyndicateIdPhoto', res.data.SynPic.toString());
      prefs.setString('oldPass', _password.text);



      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>     Directionality(
                  textDirection:
                  langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child:  homePage(res.data.id.toString())
              )
          ),
          ModalRoute.withName("/Home")
      );


    } else {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
setState(() {
  msgError=res.msg.toString();

});
    }
  }

  _buildSubmitForm(BuildContext context) async {
    String workingTime;
    pr.show();

    Map<String, dynamic> data = {
      "Email": _email.text,
      "Password": _password.text,
    };
    print(data);
    final CityRepository _repository = CityRepository();

    loginResponse res = await _repository.login(data,langSave);
    /*  apiRequest('http://api.mypharma-order.com:8080/APIS/api/Authentication/Login', {
      "Email": _email.text,
      "Password": _password.text,
    });*/

    if (res.code == "1") {
      pr.hide().then((isHidden) {
        print(isHidden);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('idu', res.data.id.toString());

      prefs.setString('sessionId', res.data.sessionId.toString());
      prefs.setString('emailp', res.data.email.toString());
      prefs.setString('pharman', res.data.PharmacyName.toString());
      prefs.setString('pharmasi', res.data.PharmacistName.toString());
      prefs.setString('long', res.data.Longitude.toString());
      prefs.setString('lat', res.data.Latidute.toString());
      prefs.setString('cityn', res.data.cityId.toString());
      prefs.setString('cityname', res.data.City.toString());

      prefs.setString('adress', res.data.Address.toString());
      prefs.setString('licnum', res.data.LicenseNumber.toString());
      prefs.setString('statusu', res.data.Status.toString());
      prefs.setString('workhour', res.data.WorkingHours.toString());
      prefs.setString('SyndicateNumber', res.data.SynNum.toString());
      prefs.setString('PharmacyPhoto', res.data.pharmaPic.toString());
      prefs.setString('SyndicateIdPhoto', res.data.SynPic.toString());
      prefs.setString('oldPass', _password.text);


      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>  Directionality(
                  textDirection:
                  langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child:  homePage(res.data.id.toString())
              )
          ),
          ModalRoute.withName("/Home")
      );
    } else {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      setState(() {
        msgError=res.msg.toString();

      });

    }
  }
}
