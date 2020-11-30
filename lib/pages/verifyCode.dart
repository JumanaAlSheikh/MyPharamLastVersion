import 'package:flutter/material.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/login.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class verifyCode extends StatefulWidget {
  final String email ;
  verifyCode(this.email);
  @override
  _verifyCode createState() => new _verifyCode();
}

class _verifyCode extends State<verifyCode> {
  final _code = TextEditingController();
  ProgressDialog pr;
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
    // blocCity.getCity();
    navigationPage();
    pr = new ProgressDialog(context);
    pr.update(
      progress: 50.0,
      message: 'Wait',
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
    return new Scaffold(
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
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 70, 30, 10),
                          child: TextField(
                            controller: _code,
                            cursorColor: Colors.praimarydark,
                            style: TextStyle(color: Colors.praimarydark),
                            decoration: InputDecoration(
                              filled: true,

                              fillColor: Colors.transparent,
                              hintText: AppLocalizations().lbVerCode,
                              hintStyle: TextStyle(
                                color: Colors.praimarydark,
                              ),
                              //can also add icon to the end of the textfiled
                              //  suffixIcon: Icon(Icons.remove_red_eye),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 40, 30, 10),
                          child: Text(
                            AppLocalizations().lbResVerCode,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 17),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                          child: Center(
                            child: RaisedButton(
                              onPressed: () {
                                _buildSubmitForm(context);

                                /*Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => login(),
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
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
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
                              )),
                          Expanded(
                              child: Text(
                            AppLocalizations().lbVerAccount,
                            style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Colors.praimarydark),
                            textAlign: TextAlign.center,
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  _buildSubmitForm(BuildContext context) async {

    pr.show();


    Map<String, dynamic> data = {
      "Email": widget.email,
      "EmailVirificationCode": int.parse(_code.text.toString()),

    };

    final CityRepository _repository = CityRepository();

    registerResponse response = await _repository.verfyAccount(data,langSave);

    if (response.code == '1') {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              Directionality(
                textDirection:
                langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child:login()),
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

}
