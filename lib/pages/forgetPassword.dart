import 'package:flutter/material.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/registerResponse.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/login.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'newPassword.dart';

class forget extends StatefulWidget {
  @override
  _forget createState() => new _forget();
}

class _forget extends State<forget> {
  final _email = TextEditingController();
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
                Container(
                  //  height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 30),
                            child:Text(
                              AppLocalizations().lbFor,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.praimarydark),
                              textAlign: TextAlign.center,
                            )
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 170, 30, 10),
                          child: TextField(
                            controller: _email,
                            cursorColor: Colors.praimarydark,
                            style: TextStyle(color: Colors.praimarydark),
                            decoration: InputDecoration(
                              filled: true,

                              fillColor: Colors.transparent,
                              hintText: AppLocalizations().lbEmail,
                              hintStyle: TextStyle(color: Colors.praimarydark,),
                              //can also add icon to the end of the textfiled
                              //  suffixIcon: Icon(Icons.remove_red_eye),
                            ),
                          ),
                        ),


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

                        GestureDetector(onTap: (){
                          Navigator.of(context).pop();

                        },child:                         Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Text(AppLocalizations().lbBackLog
                            ,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),  textAlign: TextAlign.center,),)
                          ,)
                      ],
                    ),
                    alignment: Alignment.center,
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
    pr.show();



    Map<String, dynamic> data = {
      "Email": _email.text,

    };

    final CityRepository _repository = CityRepository();

    registerResponse response = await _repository.getCodeForget(data,langSave);

    if (response.code == '1') {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>Directionality(
            textDirection:
            langSave == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: addpassword(_email.text)),
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
