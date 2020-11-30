import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:bottom_sheet_stateful/bottom_sheet_stateful.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_widget/carousel_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmas/Bloc/blocCity.dart';
import 'package:pharmas/Bloc/blocHome.dart';
import 'package:pharmas/Model/storeDrugDetails.dart';
import 'package:pharmas/lang/localss.dart';
import 'package:pharmas/pages/offers/offerDetailsPage.dart';
import 'package:pharmas/pages/Pharma/PharmaListPage.dart';

import 'package:pharmas/pages/Durgs/durgDetails.dart';
import 'package:pharmas/pages/compainDetailsHome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:pharmas/pages/reminderList.dart';
import 'package:pharmas/pages/reqPAge.dart';
import 'package:pharmas/Model/cityModel.dart';
import 'package:pharmas/Model/offerListModel.dart';
import 'package:pharmas/Repository/offerRepository.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/offerResponse.dart';
import 'package:pharmas/Model/homeManfModel.dart';
import 'package:pharmas/Model/homeOfferModel.dart';
import 'package:pharmas/Model/homePageModel.dart';
import 'package:pharmas/Model/warehouseModel.dart';
import 'package:pharmas/Repository/WareRepository.dart';
import 'package:pharmas/Repository/cityRepositry.dart';
import 'package:pharmas/Response/HomePersponse.dart';
import 'package:pharmas/Response/WareResponse.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/loginResponse.dart';
import 'package:pharmas/pages/Durgs/durgsList.dart';
import 'package:pharmas/pages/orderBeforSubmit.dart';
import 'package:pharmas/pages/offers/offerList.dart';
import 'package:pharmas/pages/compains/compainListPage.dart';
import 'package:pharmas/pages/profile.dart';
import 'package:pharmas/pages/storeDetailsPage.dart';
import 'package:pharmas/pages/addReminder.dart';

import 'package:pharmas/pages/register.dart';
import 'package:pharmas/pages/setting.dart';
import 'package:pharmas/pages/storelistdy.dart';
import 'package:pharmas/pages/verifyCode.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'forgetPassword.dart';

class homePage extends StatefulWidget {
  final String sess;

  homePage(this.sess);

  @override
  _homePage createState() => new _homePage();
}

class _homePage extends State<homePage> with SingleTickerProviderStateMixin {
  ProgressDialog pr;
  int _cIndex = 0;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  String langSave;
  BuildContext context;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
String tok;
  String sessionId, orderL, citynum;
  List<City> citylist;
  int y = 1;
  int g = 1;
  String seawa, searchePh;
  int _current = 0;
  int exit = 0;
  FocusNode focusNode;
  List<storeDrugModelDetail> listdrugitem;

  bool activeSearch = false;
  TextEditingController editingController = TextEditingController();
  bool activeSearchWare = false;
  TextEditingController editingControllerWare = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPh =
      new GlobalKey<RefreshIndicatorState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeySt =
      new GlobalKey<RefreshIndicatorState>();

  String chch, cityname;
  String idcity;

  String nameSearchPharma;
  String idcityPh;

  List<offerAllList> offerList;
  List<waresAllList> waresList;
  List<Music> orderLi;
  var preferences;
  List<String> fg;
  List waredrug;

  List<durgsHome> durgList;
  List<offerHome> adsList;
  List<manfsHome> manfList;
  List<offerAllList> tListallOffer;
  List<waresAllList> tListallWare;
  var itemsOffer = List<offerAllList>();
  var itemsWare = List<waresAllList>();
  WareResponse responseWare;

  offerResponse responseOffer;
  ScrollController _sc = new ScrollController();
  static int page = 2;
  List<offerAllList> tListOffer;
  bool isLoading = false;
  bool isLoadingWare = false;
  List<waresAllList> tListWare;
  static int pageWare = 2;
  ScrollController _scWare = new ScrollController();

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

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),
        ),
      ),
    );
  }

  Widget _buildProgressIndicatorWare() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoadingWare ? 1.0 : 00,
          child: new CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.praimarydark)),
        ),
      ),
    );
  }

  void filterSearchResults(String query) {
    activeSearch = true;

    List<offerAllList> dummySearchList = List<offerAllList>();
    dummySearchList.addAll(tListallOffer);
    if (query.isNotEmpty || query != "") {
      List<offerAllList> dummyListData = List<offerAllList>();
      dummySearchList.forEach((item) {
        print(item.Durg.toLowerCase().trimLeft());
        print(query.length.toString());
        g = query.length;
        if (item.Durg.toLowerCase()
            .trimLeft()
            .substring(0, g)
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
          // y++;
          print(g.toString());
          print(query.length.toString());
        }
      });
      setState(() {
        itemsOffer.clear();
        itemsOffer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        itemsOffer.clear();
        itemsOffer.addAll(tListallOffer);
      });
    }
  }

  void filterSearchResultsWare(String query) {
    activeSearchWare = true;
    List<waresAllList> dummySearchList = List<waresAllList>();
    dummySearchList.addAll(tListallWare);

    if (query.isNotEmpty || query != "") {
      List<waresAllList> dummyListData = List<waresAllList>();

      dummySearchList.forEach((item) {
        /*  if(waredrug==null){
         waredrug=fg;


       }else{
       waredrug=waredrug;
         waredrug=fg;

       }*/

        y = query.length;
        print(dummySearchList[dummySearchList.indexOf(item)]
            .drugList
            .listStoreDrug);

        String indexItem =
            item.drugList.listStoreDrug[waredrug.indexOf(waredrug)].name;
        if (item.Name.toLowerCase()
                .trimLeft()
                .substring(0, y)
                .contains(query.toLowerCase()) ||
            indexItem
                .toLowerCase()
                .trimLeft()
                .substring(0, y)
                .contains(query.toLowerCase())) {
          dummyListData.add(item);
          // y++;
          print(y.toString());
        }

        setState(() {
          itemsWare.clear();
          itemsWare.addAll(dummyListData);
        });
      });
      setState(() {
        itemsWare.clear();
        itemsWare.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        itemsWare.clear();
        itemsWare.addAll(tListallWare);
      });
    }
  }

  String text = 'Home';

  _getMoreData(int index) async {
    tListOffer = new List();
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      citynum = preferences.getString('cityn');
      if (citynum == null) {
        if (activeSearch == true) {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": -1,
              "Search": searchePh,
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": idcityPh,
              "Search": searchePh,
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        } else {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": -1,
              "Search": "",
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": idcityPh,
              "Search": "",
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        }
      } else {
        if (activeSearch == true) {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": citynum,
              "Search": searchePh,
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": idcityPh,
              "Search": searchePh,
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        } else {
          if (nameSearchPharma == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": citynum,
              "Search": "",
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": page,
              "Filter": idcityPh,
              "Search": "",
            };
            final offerRepository _repository = offerRepository();

            responseOffer =
                await _repository.getOfferList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseOffer.code == '1') {
              for (int i = 0;
                  i <= responseOffer.results.offers.listOffer.length;
                  i++) {
                tListOffer =
                    new List.from(responseOffer.results.offers.listOffer);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoading = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallOffer == null) {
                  tListallOffer = offerList + tListOffer;
                } else {
                  tListallOffer = tListallOffer + tListOffer;
                }

                page++;
              });
            } else {
              Toast.show(responseOffer.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        }
      }
    }
  }

  _getMoreDataWare(int index) async {
    tListWare = new List();
    if (!isLoadingWare) {
      setState(() {
        isLoadingWare = true;
      });

      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      citynum = preferences.getString('cityn');
      if (citynum == null) {
        if (activeSearchWare == true) {
          if (chch == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": -1,
              "Search": seawa,
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": idcity,
              "Search": seawa,
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        } else {
          if (chch == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": -1,
              "Search": "",
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": idcity,
              "Search": "",
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        }
      } else {
        if (activeSearchWare == true) {
          if (chch == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": citynum,
              "Search": seawa,
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": idcity,
              "Search": seawa,
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        } else {
          if (chch == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": citynum,
              "Search": "",
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": pageWare,
              "Filter": idcity,
              "Search": "",
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
//offerList = response.results.offers.listOffer;
            //   response = blocOffer.getOfferList(sessionId, data);
            if (responseWare.code == '1') {
              for (int i = 0;
                  i <= responseWare.results.wares.listWare.length;
                  i++) {
                tListWare = new List.from(responseWare.results.wares.listWare);
                //  tList.add(offerList[i]);
              }

              setState(() {
                isLoadingWare = false;
                //  offerList.addAll(tList);
                //  offerList= new List.from(tList,tListall);
                if (tListallWare == null) {
                  tListallWare = waresList + tListWare;
                } else {
                  tListallWare = tListallWare + tListWare;
                }

                pageWare++;
              });
            } else {
              Toast.show(responseWare.msg.toString(), context,
                  duration: 4, gravity: Toast.BOTTOM);
            }
          }
        }
      }
    }
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
    navigationPage();
    fg = new List<String>();
    activeSearch = false;
    activeSearchWare = false;
    blocCity.getCity(langSave);
    getValueString();
    focusNode = FocusNode();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });

    _scWare.addListener(() {
      if (_scWare.position.pixels == _scWare.position.maxScrollExtent) {
        _getMoreDataWare(pageWare);
      }
    });

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

  getValueString() async {
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() async {
        tok=token;
        //   _homeScreenText = "Push Messaging token: $token";
        preferences = await SharedPreferences.getInstance();
        sessionId = preferences.getString('sessionId');
        Map<String, dynamic> data = {
          "FCMToken": tok,
          "DeviceType": 'Android',
          "OldFCMToken": tok,
        };

        blocHome.setToken(sessionId, data, langSave);
      });
      print(token);
    });

    if (text == 'Home') {
      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      print(sessionId);
      setState(() {
        orderL = preferences.getString('mou');
        if (orderL != null) {
          orderLi = (json.decode(orderL) as List<dynamic>)
              .map<Music>((item) => Music.fromJson(item))
              .toList();
        }
      });
      print(orderLi);
      Map<String, dynamic> data = {
        "PageSize": 10,
        "PageNumber": 1,
        "Filter": 1,
        "Search": "",
      };

      blocHome.getHomeList(sessionId, data, langSave);
    } else if (text == 'Pharma') {
      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      citynum = preferences.getString('cityn');
      cityname = preferences.getString('cityname');
      if (idcityPh == null) {
        if (citynum == null) {
          idcityPh = '-1';
        } else {
          idcityPh = null;
        }
      }
      if (citynum == null) {
        if (idcityPh == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": 1,
            "Filter": -1,
            "Search": "",
          };
          // blocOffer.getOfferList(sessionId, data);
          print(data);

          final offerRepository _repository = offerRepository();

          responseOffer =
              await _repository.getOfferList(sessionId, data, langSave);
          setState(() {
            tListallOffer = responseOffer.results.offers.listOffer;
            itemsOffer.addAll(tListallOffer);
          });
        } else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": 1,
            "Filter": idcityPh,
            "Search": "",
          };
          print(data);
          final offerRepository _repository = offerRepository();

          responseOffer =
              await _repository.getOfferList(sessionId, data, langSave);
          setState(() {
            tListallOffer = responseOffer.results.offers.listOffer;
            itemsOffer.addAll(tListallOffer);
          });
        }
      } else {
        if (idcityPh == null) {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": 1,
            "Filter": citynum,
            "Search": "",
          };
          // blocOffer.getOfferList(sessionId, data);
          print(data);

          final offerRepository _repository = offerRepository();

          responseOffer =
              await _repository.getOfferList(sessionId, data, langSave);
          setState(() {
            tListallOffer = responseOffer.results.offers.listOffer;
            itemsOffer.addAll(tListallOffer);
          });
        } else {
          Map<String, dynamic> data = {
            "PageSize": 10,
            "PageNumber": 1,
            "Filter": idcityPh,
            "Search": "",
          };
          print(data);
          final offerRepository _repository = offerRepository();

          responseOffer =
              await _repository.getOfferList(sessionId, data, langSave);
          setState(() {
            tListallOffer = responseOffer.results.offers.listOffer;
            itemsOffer.addAll(tListallOffer);
          });
        }
      }
    } else if (text == 'Store') {
      preferences = await SharedPreferences.getInstance();
      sessionId = preferences.getString('sessionId');
      citynum = preferences.getString('cityn');
      cityname = preferences.getString('cityname');

      print(citynum);
      print(idcity);
      if (idcity == null) {
        if (citynum == null) {
          idcity = '-1';
        } else {
          idcity = null;
        }
      }
      if (activeSearchWare == true) {
        if (citynum == null) {
          if (idcity == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": -1,
              "Search": seawa,
            };
            // blocOffer.getOfferList(sessionId, data);
            print(data);
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": idcity,
              "Search": seawa,
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          }
        } else {
          if (idcity == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": citynum,
              "Search": seawa,
            };
            print(data);
            // blocOffer.getOfferList(sessionId, data);

            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": idcity,
              "Search": seawa,
            };
            print(data);

            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          }
        }
      } else {
        if (citynum == null) {
          if (idcity == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": -1,
              "Search": "",
            };
            // blocOffer.getOfferList(sessionId, data);
            print(data);
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": idcity,
              "Search": "",
            };
            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          }
        } else {
          if (idcity == null) {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": citynum,
              "Search": "",
            };
            print(data);
            // blocOffer.getOfferList(sessionId, data);

            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          } else {
            Map<String, dynamic> data = {
              "PageSize": 10,
              "PageNumber": 1,
              "Filter": idcity,
              "Search": "",
            };
            print(data);

            final WareRepository _repository = WareRepository();

            responseWare =
                await _repository.getWareList(sessionId, data, langSave);
            setState(() {
              tListallWare = responseWare.results.wares.listWare;
              itemsWare.addAll(tListallWare);
            });
          }
        }
      }

      itemsWare.forEach((item) {
        //  fg.clear();
        int indexItem = itemsWare.indexOf(item);
        //  dummySearchList

        listdrugitem = itemsWare[indexItem].drugList.listStoreDrug;
        for (int j = 0;
            j < itemsWare[indexItem].drugList.listStoreDrug.length;
            j++) {
          fg.add(listdrugitem[j].name);

          waredrug = fg;
        }
      });
      print(fg);
      print(waredrug);
    }
  }

  _onTap(int index) async {
    switch (index) {
      case 0:
        setState(() {
          text = 'Home';
          idcity = null;
          idcityPh = null;

          nameSearchPharma = null;
          searchePh = null;
        });
        initState();

        break;
      case 1:
        setState(() {
          text = 'Store';
          // idcity='-1';

          idcityPh = null;
          nameSearchPharma = null;
          chch = null;
        });
        initState();

        break;
      case 2:
        setState(() {
          text = 'Pharma';
          idcity = null;
          //  idcityPh=-1;
          nameSearchPharma = null;
          chch = null;
        });
        initState();

        break;
      case 3:
        setState(() {
          if (text == 'Home') {
            text == 'Home';
          } else if (text == 'Pharma') {
            text == 'Pharma';
          } else if (text == 'Store') {
            text == 'Store';
          }
        });
        await _newTaskModalBottomSheet(context);
        break;
      default:
        setState(() => text = 'Home');
    }
  }

  PreferredSizeWidget _appBar() {
    if (activeSearch) {
      return AppBar(
        leading: Icon(Icons.search),
        title: TextField(
          focusNode: focusNode,
          onChanged: (value) {
            filterSearchResults(value);
            searchePh = value;
          },
          controller: editingController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white)),
            labelStyle: new TextStyle(color: Colors.white),
            hintText: AppLocalizations().lbEnDrugN,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                activeSearch = false;
                editingController.clear();
                itemsOffer.clear();
                itemsOffer.addAll(tListallOffer);
              });
            },
          )
        ],
      );
    } else {
      return AppBar(
        leading: orderLi != null
            ? orderLi.length != 0
                ? orderLi[0].session == widget.sess
                    ? GestureDetector(
                        child: Visibility(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Icon(
                              Icons.local_grocery_store,
                              color: Colors.white,
                            ),
                          ),
                          visible: true,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => Directionality(
                                  textDirection: langSave == 'ar'
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: orderBeforSub()),
                            ),
                          );
                        },
                      )
                    : Visibility(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Icon(
                            Icons.local_grocery_store,
                            color: Colors.white,
                          ),
                        ),
                        visible: false,
                      )
                : Visibility(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Icon(
                        Icons.local_grocery_store,
                        color: Colors.white,
                      ),
                    ),
                    visible: false,
                  )
            : Visibility(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Icon(
                    Icons.local_grocery_store,
                    color: Colors.white,
                  ),
                ),
                visible: false,
              ),
        title: Text("Offers"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() => activeSearch = true);
              focusNode.requestFocus();
            },
          ),
        ],
      );
    }
  }

  PreferredSizeWidget _appBarWare() {
    if (activeSearchWare) {
      return AppBar(
        leading: Icon(Icons.search),
        title: TextField(
          focusNode: focusNode,
          onChanged: (value) {
            //   filterSearchResultsWare(value);
            seawa = value;
            if (value.isNotEmpty || value != "") {
              tListallWare.clear();
              itemsWare.clear();
              getValueString();
            } else {
              activeSearchWare = false;
              editingControllerWare.clear();
              tListallWare.clear();
              itemsWare.clear();
              getValueString();
            }
          },
          controller: editingControllerWare,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white)),
            labelStyle: new TextStyle(color: Colors.white),
            hintText: AppLocalizations().lbEnDrugW,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                activeSearchWare = false;
                editingControllerWare.clear();
                itemsWare.clear();
                itemsWare.addAll(tListallWare);
              });
            },
          )
        ],
      );
    } else {
      return AppBar(
        leading: orderLi != null
            ? orderLi.length != 0
                ? orderLi[0].session == widget.sess
                    ? GestureDetector(
                        child: Visibility(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Icon(
                              Icons.local_grocery_store,
                              color: Colors.white,
                            ),
                          ),
                          visible: true,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => Directionality(
                                  textDirection: langSave == 'ar'
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: orderBeforSub()),
                            ),
                          );
                        },
                      )
                    : Visibility(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Icon(
                            Icons.local_grocery_store,
                            color: Colors.white,
                          ),
                        ),
                        visible: false,
                      )
                : Visibility(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Icon(
                        Icons.local_grocery_store,
                        color: Colors.white,
                      ),
                    ),
                    visible: false,
                  )
            : Visibility(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Icon(
                    Icons.local_grocery_store,
                    color: Colors.white,
                  ),
                ),
                visible: false,
              ),
        title: Text(AppLocalizations().lbWare),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() => activeSearchWare = true);
              focusNode.requestFocus();
            },
          ),
        ],
      );
    }
  }

  Future<void> _refresh() async {
    // dummy code

    getValueString();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.context = context);

    return new WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: false,
        appBar: text == 'Pharma'
            ? _appBar()
            : text == 'Store'
                ? _appBarWare()
                : AppBar(
                    title: new Text(
                      AppLocalizations().lbHome,
                      textAlign: TextAlign.center,
                    ),
                    centerTitle: true,
                    leading: orderLi != null
                        ? orderLi.length != 0
                            ? orderLi[0].session == widget.sess
                                ? GestureDetector(
                                    child: Visibility(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: Icon(
                                          Icons.local_grocery_store,
                                          color: Colors.white,
                                        ),
                                      ),
                                      visible: true,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              Directionality(
                                                  textDirection:
                                                      langSave == 'ar'
                                                          ? TextDirection.rtl
                                                          : TextDirection.ltr,
                                                  child: orderBeforSub()),
                                        ),
                                      );
                                    },
                                  )
                                : Visibility(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Icon(
                                        Icons.local_grocery_store,
                                        color: Colors.white,
                                      ),
                                    ),
                                    visible: false,
                                  )
                            : Visibility(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Icon(
                                    Icons.local_grocery_store,
                                    color: Colors.white,
                                  ),
                                ),
                                visible: false,
                              )
                        : Visibility(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Icon(
                                Icons.local_grocery_store,
                                color: Colors.white,
                              ),
                            ),
                            visible: false,
                          )),
        body: text == 'Home'
            ? RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: StreamBuilder(
                  stream: blocHome.subject.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<HomeResponse> snapshot) {
                    if (snapshot.hasData) {
                      /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

                      durgList =
                          snapshot.data.resultsDurg.durgsHome.listdurgsHome;
                      manfList =
                          snapshot.data.resultsManf.manfHome.listmanfHome;
                      adsList =
                          snapshot.data.resultsOffer.offerHome.listofferHome;
                      return new ListView.builder(
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return new Padding(
                              padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                              child: Column(
                                children: <Widget>[
                                  adsList.length == 0
                                      ? Visibility(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 5, 0, 25),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        AppLocalizations()
                                                            .lbOffer,
                                                        style:
                                                            TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .praimarydark,
                                                                fontSize: 17)),
                                                    new Spacer(),
                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color:
                                                          Colors.praimarydark,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 250,
                                                child: Stack(
                                                  children: <Widget>[
                                                    CarouselSlider(
                                                        items: adsList.map((i) {
                                                          return Builder(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              5.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(
                                                                              20)),
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                AssetImage('assets/images/slider.jpg'),
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          )),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        i.typeName,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                            color:
                                                                                Colors.praimarydark,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                      Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              0,
                                                                              10,
                                                                              0,
                                                                              15),
                                                                          child:
                                                                              Text(
                                                                            i.offerName,
                                                                            style:
                                                                                TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                          ))
                                                                    ],
                                                                  ));
                                                            },
                                                          );
                                                        }).toList(),
                                                        options:
                                                            CarouselOptions(
                                                          height: 250,
                                                          onPageChanged:
                                                              (index, reason) {
                                                            setState(() {
                                                              _current = index;
                                                            });
                                                          },
                                                          initialPage: 0,
                                                          //  enableInfiniteScroll: true,
                                                          // reverse: false,
                                                          autoPlay: true,
                                                          autoPlayInterval:
                                                              Duration(
                                                                  seconds: 15),
                                                          //autoPlayAnimationDuration: Duration(milliseconds: 800),
                                                          //autoPlayCurve: Curves.fastOutSlowIn,
                                                          enlargeCenterPage:
                                                              true,
                                                          // scrollDirection: Axis.horizontal,
                                                        )),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children:
                                                            adsList.map((url) {
                                                          int index = adsList
                                                              .indexOf(url);
                                                          return Container(
                                                            width: 8.0,
                                                            height: 8.0,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10.0,
                                                                    horizontal:
                                                                        2.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: _current ==
                                                                      index
                                                                  ? Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.9)
                                                                  : Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.4),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          visible: false,
                                        )
                                      : Visibility(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 5, 0, 25),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        AppLocalizations()
                                                            .lbAds,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .praimarydark,
                                                            fontSize: 17)),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 250,
                                                child: Stack(
                                                  children: <Widget>[
                                                    CarouselSlider(
                                                      items: adsList.map((i) {
                                                        return Builder(
                                                          builder: (BuildContext
                                                              context) {
                                                            return Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(
                                                                                20)),
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              AssetImage('assets/images/slider.jpg'),
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        )),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      i.typeName,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color: Colors
                                                                              .praimarydark,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            10,
                                                                            0,
                                                                            15),
                                                                        child:
                                                                            Text(
                                                                          i.offerName,
                                                                          style: TextStyle(
                                                                              fontSize: 16.0,
                                                                              color: Colors.praimarydark),
                                                                        )),
                                                                    i.type.toString() ==
                                                                            '2'
                                                                        ? Visibility(
                                                                            visible:
                                                                                true,
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                    child: Text(
                                                                                      AppLocalizations().lbWare + ' : ' + i.warename,
                                                                                      style: TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                                    )),
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                    child: Text(
                                                                                      AppLocalizations().lbDrugN + ' : ' + i.drugname,
                                                                                      style: TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                                    )),
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                                    child: Text(
                                                                                      AppLocalizations().lbPrice + ' : ' + i.price.split('.')[0],
                                                                                      style: TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                                    ))
                                                                              ],
                                                                            ))
                                                                        : Visibility(
                                                                            visible:
                                                                                false,
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                                                                    child: Text(
                                                                                      i.warename,
                                                                                      style: TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                                    )),
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                                                                    child: Text(
                                                                                      i.drugname,
                                                                                      style: TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                                    )),
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                                                                    child: Text(
                                                                                      i.price.split('.')[0],
                                                                                      style: TextStyle(fontSize: 16.0, color: Colors.praimarydark),
                                                                                    ))
                                                                              ],
                                                                            ))
                                                                  ],
                                                                ));
                                                          },
                                                        );
                                                      }).toList(),
                                                      options: CarouselOptions(
                                                        height: 250,
                                                        onPageChanged:
                                                            (index, reason) {
                                                          setState(() {
                                                            _current = index;
                                                          });
                                                        },
                                                        initialPage: 0,

                                                        //  enableInfiniteScroll: true,
                                                        // reverse: false,
                                                        autoPlay: true,
                                                        autoPlayInterval:
                                                            Duration(
                                                                seconds: 15),
                                                        //autoPlayAnimationDuration: Duration(milliseconds: 800),
                                                        //autoPlayCurve: Curves.fastOutSlowIn,
                                                        enlargeCenterPage: true,
                                                        // scrollDirection: Axis.horizontal,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children:
                                                            adsList.map((url) {
                                                          int index = adsList
                                                              .indexOf(url);
                                                          return Container(
                                                            width: 8.0,
                                                            height: 8.0,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10.0,
                                                                    horizontal:
                                                                        2.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: _current ==
                                                                      index
                                                                  ? Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.9)
                                                                  : Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.4),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          visible: true,
                                        ),
                                  durgList.length == 0
                                      ? Visibility(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 15, 0, 0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        AppLocalizations()
                                                            .lbDrug,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .praimarydark,
                                                            fontSize: 17)),
                                                    new Spacer(),
                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color:
                                                          Colors.praimarydark,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 270,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: durgList.length,
                                                    itemBuilder:
                                                        (BuildContext ctxt,
                                                            int index) {
                                                      return new Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 20, 10, 10),
                                                        child: Container(
                                                          width: 120,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(10,
                                                                    20, 10, 5),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          50,
                                                                          0,
                                                                          5),
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            10,
                                                                            30,
                                                                            10,
                                                                            1),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              durgList[index].CommerceName.toString(),
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            3,
                                                                            0,
                                                                            1),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              durgList[index].ScientificName.toString(),
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            3,
                                                                            0,
                                                                            1),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              durgList[index].Strengths.toString(),
                                                                              style: TextStyle(color: Colors.white),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            3,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              durgList[index].Category.toString(),
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          18,
                                                                          0,
                                                                          10),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        durgList[index]
                                                                            .Manufacture
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                            image: AssetImage(
                                                                'assets/images/durgcardhome.png'),
                                                            fit: BoxFit.fill,
                                                          )),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                          visible: false,
                                        )
                                      : Visibility(
                                          child: Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                          AppLocalizations()
                                                              .lbDrug,
                                                          style:
                                                              TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .praimarydark,
                                                                  fontSize:
                                                                      17)),
                                                      new Spacer(),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_right,
                                                        color:
                                                            Colors.praimarydark,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          Directionality(
                                                              textDirection: langSave ==
                                                                      'ar'
                                                                  ? TextDirection
                                                                      .rtl
                                                                  : TextDirection
                                                                      .ltr,
                                                              child:
                                                                  durgsList()),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Container(
                                                height: 225,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: 4,
                                                    itemBuilder:
                                                        (BuildContext ctxt,
                                                            int index) {
                                                      return new Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 20, 10, 10),
                                                        child: GestureDetector(
                                                          child: Container(
                                                            width: 130,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          10,
                                                                          0),
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            74,
                                                                            0,
                                                                            5),
                                                                    child:
                                                                        Column(
                                                                      children: <
                                                                          Widget>[
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              10,
                                                                              0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                  child: Text(
                                                                                    durgList[index].CommerceName.toString(),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  width: 90),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              0,
                                                                              1,
                                                                              0,
                                                                              1),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                  child: Text(
                                                                                    durgList[index].ScientificName.toString(),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                  width: 90)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              0,
                                                                              15,
                                                                              0,
                                                                              0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                durgList[index].Category.toString(),
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            10,
                                                                            0,
                                                                            0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          durgList[index]
                                                                              .Manufacture
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/images/durgcardhome.png'),
                                                              fit: BoxFit.fill,
                                                            )),
                                                          ),
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              PageRouteBuilder(
                                                                pageBuilder: (_, __, ___) => Directionality(
                                                                    textDirection: langSave ==
                                                                            'ar'
                                                                        ? TextDirection
                                                                            .rtl
                                                                        : TextDirection
                                                                            .ltr,
                                                                    child: durgDetails(
                                                                        durgList[index]
                                                                            .CommerceName,
                                                                        durgList[index]
                                                                            .id,
                                                                        '1')),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                          visible: true,
                                        ),
                                  manfList.length == 0
                                      ? Visibility(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 15, 0, 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        AppLocalizations()
                                                            .lbCom,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .praimarydark,
                                                            fontSize: 17)),
                                                    new Spacer(),
                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color:
                                                          Colors.praimarydark,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                //height: 400,
                                                child: Wrap(
                                                  children: <Widget>[
                                                    GridView.count(
                                                        crossAxisCount: 2,
                                                        shrinkWrap: true,
                                                        childAspectRatio: 1.0,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        mainAxisSpacing: 4.0,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        crossAxisSpacing: 6.0,
                                                        children:
                                                            manfList.map((url) {
                                                          int index = manfList
                                                              .indexOf(url);
                                                          return GridTile(
                                                              child: Container(
                                                                  height: 250,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      manfList[index].icon ==
                                                                              null
                                                                          ? new Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 90,
                                                                              decoration: new BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  image: new DecorationImage(
                                                                                      fit: BoxFit.fill,
                                                                                      image: new AssetImage(
                                                                                        'assets/images/compains.png',
                                                                                      ))))
                                                                          : Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 90,
                                                                              decoration: new BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  image: new DecorationImage(
                                                                                    fit: BoxFit.fill,
                                                                                    image: new NetworkImage(
                                                                                      'http://mypharma-order.com/files/images/manufacturers/large/' + manfList[index].icon,
                                                                                    ),
                                                                                  ))),
                                                                      manfList[index].manfName !=
                                                                              null
                                                                          ? Text(
                                                                              manfList[index].manfName,
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                                                                            )
                                                                          : Text(
                                                                              '',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/images/compaincardhome.png'),
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ))));
                                                        }).toList())
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          visible: false,
                                        )
                                      : Visibility(
                                          child: Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          Directionality(
                                                              textDirection:
                                                                  langSave ==
                                                                          'ar'
                                                                      ? TextDirection
                                                                          .rtl
                                                                      : TextDirection
                                                                          .ltr,
                                                              child:
                                                                  compainListPage()),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                          AppLocalizations()
                                                              .lbCom,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .praimarydark,
                                                              fontSize: 17)),
                                                      new Spacer(),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_right,
                                                        color:
                                                            Colors.praimarydark,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 15, 0, 0),
                                                child: Container(
                                                  //height: 400,
                                                  child: Wrap(
                                                    children: <Widget>[
                                                      GridView.count(
                                                          crossAxisCount: 2,
                                                          shrinkWrap: true,
                                                          childAspectRatio: 1.0,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          mainAxisSpacing: 4.0,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          crossAxisSpacing: 6.0,
                                                          children: manfList
                                                              .map((url) {
                                                            int index = manfList
                                                                .indexOf(url);
                                                            return GridTile(
                                                                child:
                                                                    GestureDetector(
                                                              child: Container(
                                                                  height: 250,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      manfList[index].icon ==
                                                                              null
                                                                          ? new Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 100,
                                                                              child: Image.asset(
                                                                                'assets/images/compains.png',
                                                                                fit: BoxFit.fill,
                                                                              ),
                                                                            )
                                                                          : Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 100,
                                                                              child: Image.network(
                                                                                'http://mypharma-order.com/files/images/manufacturers/large/' + manfList[index].icon,
                                                                                fit: BoxFit.fill,
                                                                              ),
                                                                            ),
                                                                      manfList[index].manfName !=
                                                                              null
                                                                          ? Text(
                                                                              manfList[index].manfName,
                                                                              style: TextStyle(color: Colors.black, fontSize: 15),
                                                                            )
                                                                          : Text(
                                                                              '',
                                                                              style: TextStyle(color: Colors.black, fontSize: 15),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/images/compaincardhome.png'),
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ))),
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) => Directionality(
                                                                        textDirection: langSave ==
                                                                                'ar'
                                                                            ? TextDirection
                                                                                .rtl
                                                                            : TextDirection
                                                                                .ltr,
                                                                        child: compainDetailsHome(
                                                                            manfList[index])),
                                                                  ),
                                                                );
                                                              },
                                                            ));
                                                          }).toList())
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          visible: true,
                                        )
                                ],
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Text('error');
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.praimarydark)),
                      );
                    }
                  },
                ))
            : text == 'Pharma'
                ? RefreshIndicator(
                    key: _refreshIndicatorKeyPh,
                    onRefresh: _refresh,
                    child: StreamBuilder(
                      stream: blocCity.subject.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<CityResponse> snapshot) {
                        if (snapshot.hasData) {
                          /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

                          citylist = snapshot.data.results.citiesr.cities;

                          return new Container(
                              child: tListallOffer == null
                                  ? Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.praimarydark)))
                                  : Container(
                                      color: Colors.white,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                30, 0, 30, 0),
                                            child: Row(
                                              children: <Widget>[
                                                GestureDetector(
                                                  child: Row(
                                                    children: <Widget>[
                                                      nameSearchPharma == null
                                                          ? citynum == null
                                                              ? Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          15,
                                                                          0,
                                                                          5),
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(AppLocalizations()
                                                                          .lbFil)
                                                                    ],
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          15,
                                                                          0,
                                                                          5),
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(AppLocalizations()
                                                                              .lbFil +
                                                                          cityname)
                                                                    ],
                                                                  ),
                                                                )
                                                          : Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          5,
                                                                          5,
                                                                          5,
                                                                          5),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  Text(AppLocalizations()
                                                                          .lbFil +
                                                                      ' $nameSearchPharma')
                                                                ],
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    displayBottomSheetPh(
                                                        context, citylist);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                          activeSearch == true
                                              ? Expanded(
                                                  child: ListView.builder(
                                                  itemCount:
                                                      itemsOffer.length + 1,
                                                  // Add one more item for progress indicator
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    if (index ==
                                                        itemsOffer.length) {
                                                      return _buildProgressIndicator();
                                                    } else {
                                                      return new Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 30, 10, 0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              PageRouteBuilder(
                                                                pageBuilder: (_, __, ___) => Directionality(
                                                                    textDirection: langSave ==
                                                                            'ar'
                                                                        ? TextDirection
                                                                            .rtl
                                                                        : TextDirection
                                                                            .ltr,
                                                                    child: offerDetails(
                                                                        itemsOffer[
                                                                            index])),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                    image: itemsOffer[index].Gift ==
                                                                            ""
                                                                        ? AssetImage(
                                                                            'assets/images/discount.jpg')
                                                                        : AssetImage(
                                                                            'assets/images/gift.jpg'),
                                                                    fit: BoxFit
                                                                        .fill)),
                                                            child: itemsOffer[
                                                                            index]
                                                                        .Gift ==
                                                                    ""
                                                                ? Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            20,
                                                                            0,
                                                                            20,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                                              child: Container(
                                                                                constraints: new BoxConstraints(maxWidth: 100),
                                                                                child: Text(itemsOffer[index].Durg, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.praimarydark)),
                                                                                height: 50,
                                                                              ),
                                                                            ),
                                                                            new Spacer(),
                                                                            Row(
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                  child: itemsOffer[index].mane!=null?
                                                                                  Text(itemsOffer[index].mane, style: TextStyle(color: Colors.red)):
                                                                                  Text('', style: TextStyle(color: Colors.red)),
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            // new Spacer(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbDis + ' : ' + itemsOffer[index].Discount + ' % ',
                                                                            ),
                                                                            new Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Text(AppLocalizations().lbDrugEx + ' : '),
                                                                                  Padding(
                                                                                    child: Text(itemsOffer[index].drugExDa.substring(0, 10)),
                                                                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: <Widget>[
                                                                                Text(AppLocalizations().lbPhPrice + ' : '),
                                                                                Padding(
                                                                                  child: Text(itemsOffer[index].Price.split('.')[0]),
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Text(AppLocalizations().lbGePrice + ' : '),
                                                                                  Padding(
                                                                                    child: Text(itemsOffer[index].NormalPrice.split('.')[0]),
                                                                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: <Widget>[
                                                                                Text(AppLocalizations().lbQuan + ' : '),
                                                                                Padding(
                                                                                  child: Text(itemsOffer[index].Quantity),
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Text(AppLocalizations().lbToPrice + ' : ', style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                  Padding(
                                                                                    child: Text(itemsOffer[index].TotalPrice.split('.')[0], style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            15),
                                                                        child:
                                                                            Align(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Text(AppLocalizations().lbExDateOff + ' : '),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  child: Text(itemsOffer[index].ExpiryDate.substring(0, 10)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )
                                                                : Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            20,
                                                                            0,
                                                                            20,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                                                child: Container(
                                                                                  constraints: new BoxConstraints(maxWidth: 100),
                                                                                  child: Text(itemsOffer[index].Durg, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.praimarydark)),
                                                                                  height: 50,
                                                                                )),
                                                                            Row(
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                  child:itemsOffer[index].mane!=null?
                                                                                  Text(itemsOffer[index].mane, style: TextStyle(color: Colors.red)):
                                                            Text('', style: TextStyle(color: Colors.red)),

                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                )
                                                                              ],
                                                                            ), // new Spacer(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              AppLocalizations().lbGift + ' : ' + itemsOffer[index].Gift,
                                                                            ),
                                                                            new Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Text(AppLocalizations().lbDrugEx + ' : '),
                                                                                  Padding(
                                                                                    child: Text(itemsOffer[index].drugExDa.substring(0, 10)),
                                                                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: <Widget>[
                                                                                Text(AppLocalizations().lbPhPrice + ' : '),
                                                                                Padding(
                                                                                  child: Text(itemsOffer[index].Price.split('.')[0]),
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Text(AppLocalizations().lbGePrice + ' : '),
                                                                                  Padding(
                                                                                    child: Text(itemsOffer[index].NormalPrice.split('.')[0]),
                                                                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            5),
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Row(
                                                                              children: <Widget>[
                                                                                Text(AppLocalizations().lbQuan + ' : '),
                                                                                Padding(
                                                                                  child: Text(itemsOffer[index].Quantity),
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            new Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Text(AppLocalizations().lbToPrice + ' : ', style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                  Padding(
                                                                                    child: Text(itemsOffer[index].TotalPrice.split('.')[0], style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            15,
                                                                            5,
                                                                            15,
                                                                            15),
                                                                        child:
                                                                            Align(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Text(AppLocalizations().lbExDateOff + ' : '),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                  child: Text(itemsOffer[index].ExpiryDate.substring(0, 10)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  controller: _sc,
                                                ))
                                              : tListallOffer == null
                                                  ? Container()
                                                  : Expanded(
                                                      child: ListView.builder(
                                                      itemCount:
                                                          tListallOffer.length +
                                                              1,
                                                      // Add one more item for progress indicator
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.0),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        if (index ==
                                                            tListallOffer
                                                                .length) {
                                                          return _buildProgressIndicator();
                                                        } else {
                                                          return new Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(10,
                                                                    30, 10, 0),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (_, __, ___) => Directionality(
                                                                        textDirection: langSave ==
                                                                                'ar'
                                                                            ? TextDirection
                                                                                .rtl
                                                                            : TextDirection
                                                                                .ltr,
                                                                        child: offerDetails(
                                                                            tListallOffer[index])),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                        image: tListallOffer[index].Gift ==
                                                                                ""
                                                                            ? AssetImage(
                                                                                'assets/images/discount.jpg')
                                                                            : AssetImage(
                                                                                'assets/images/gift.jpg'),
                                                                        fit: BoxFit
                                                                            .fill)),
                                                                child: tListallOffer[index]
                                                                            .Gift ==
                                                                        ""
                                                                    ? Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                20,
                                                                                0,
                                                                                20,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                                                  child: Container(
                                                                                    constraints: new BoxConstraints(maxWidth: 100),
                                                                                    child: Text(tListallOffer[index].Durg, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.praimarydark)),
                                                                                    height: 50,
                                                                                  ),
                                                                                ),
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Padding(
                                                                                      child:tListallOffer[index].mane!=null?
                                                                                      Text(tListallOffer[index].mane,
                                                                                          style:
                                                                                          TextStyle(color: Colors.red)):
                                                                                      Text('',
                                                                                          style:
                                                                                          TextStyle(color: Colors.red)),
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                // new Spacer(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  AppLocalizations().lbDis + ' : ' + tListallOffer[index].Discount + ' % ',
                                                                                ),
                                                                                new Spacer(),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Text(AppLocalizations().lbDrugEx + ' : '),
                                                                                      Padding(
                                                                                        child: Text(tListallOffer[index].drugExDa.substring(0, 10)),
                                                                                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Text(AppLocalizations().lbPhPrice + ' : '),
                                                                                    Padding(
                                                                                      child: Text(tListallOffer[index].Price.split('.')[0]),
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                new Spacer(),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Text(AppLocalizations().lbGePrice + ' : '),
                                                                                      Padding(
                                                                                        child: Text(tListallOffer[index].NormalPrice.split('.')[0]),
                                                                                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Text(AppLocalizations().lbQuan + ' : '),
                                                                                    Padding(
                                                                                      child: Text(tListallOffer[index].Quantity),
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                new Spacer(),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Text(AppLocalizations().lbToPrice + ' : ', style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                      Padding(
                                                                                        child: Text(tListallOffer[index].TotalPrice.split('.')[0], style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                15),
                                                                            child:
                                                                                Align(
                                                                              child: Container(
                                                                                child: Row(
                                                                                  children: <Widget>[
                                                                                    Text(AppLocalizations().lbExDateOff + ' : '),
                                                                                    Padding(
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      child: Text(tListallOffer[index].ExpiryDate.substring(0, 10)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                20,
                                                                                0,
                                                                                20,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                                                    child: Container(
                                                                                      constraints: new BoxConstraints(maxWidth: 100),
                                                                                      child: Text(tListallOffer[index].Durg, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.praimarydark)),
                                                                                      height: 50,
                                                                                    )),
                                                                                // new Spacer(),
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Padding(
                                                                                      child: tListallOffer[index].mane!=null?Text(tListallOffer[index].mane,
                                                                                          style: TextStyle(color: Colors.red)):
                                                                                      Text('',
                                                                                          style: TextStyle(color: Colors.red)),
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  AppLocalizations().lbGift + ' : ' + tListallOffer[index].Gift,
                                                                                ),
                                                                                new Spacer(),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Text(AppLocalizations().lbDrugEx + ' : '),
                                                                                      Padding(
                                                                                        child: Text(tListallOffer[index].drugExDa.substring(0, 10)),
                                                                                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Text(AppLocalizations().lbPhPrice + ' : '),
                                                                                    Padding(
                                                                                      child: Text(tListallOffer[index].Price.split('.')[0]),
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                new Spacer(),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Text(AppLocalizations().lbGePrice + ' : '),
                                                                                      Padding(
                                                                                        child: Text(tListallOffer[index].NormalPrice.split('.')[0]),
                                                                                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                5),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: <Widget>[
                                                                                    Text(AppLocalizations().lbQuan + ' : '),
                                                                                    Padding(
                                                                                      child: Text(tListallOffer[index].Quantity),
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                new Spacer(),
                                                                                Padding(
                                                                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Text(AppLocalizations().lbToPrice + ' : ', style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                      Padding(
                                                                                        child: Text(tListallOffer[index].TotalPrice.split('.')[0], style: TextStyle(color: Colors.deepOrangeAccent)),
                                                                                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                15,
                                                                                5,
                                                                                15,
                                                                                15),
                                                                            child:
                                                                                Align(
                                                                              child: Container(
                                                                                child: Row(
                                                                                  children: <Widget>[
                                                                                    Text(AppLocalizations().lbExDateOff + ' : '),
                                                                                    Padding(
                                                                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                                      child: Text(tListallOffer[index].ExpiryDate.substring(0, 10)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      controller: _sc,
                                                    )),
                                        ],
                                      ),
                                    ));
                        } else if (snapshot.hasError) {
                          return Text('error');
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.praimarydark)),
                          );
                        }
                      },
                    ),
                  )
                : text == 'Store'
                    ? RefreshIndicator(
                        key: _refreshIndicatorKeyPh,
                        onRefresh: _refresh,
                        child: StreamBuilder(
                          stream: blocCity.subject.stream,
                          builder: (BuildContext context,
                              AsyncSnapshot<CityResponse> snapshot) {
                            if (snapshot.hasData) {
                              /*if (snapshot.data.error != null && snapshot.data.error.length > 0) {
          return ErrorHandle(snapshot.data.error);
        }*/

                              citylist = snapshot.data.results.citiesr.cities;
                              return new Container(
                                child: itemsWare.length == 0
                                    ? Center(
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                        Color>(
                                                    Colors.praimarydark)))
                                    : Container(
                                        color: Colors.white,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  30, 0, 30, 0),
                                              child: Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    child: Row(
                                                      children: <Widget>[
                                                        chch == null
                                                            ? citynum == null
                                                                ? Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            15,
                                                                            0,
                                                                            5),
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Text(AppLocalizations()
                                                                            .lbFilA)
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            15,
                                                                            0,
                                                                            5),
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Text(AppLocalizations().lbFil +
                                                                            cityname)
                                                                      ],
                                                                    ),
                                                                  )
                                                            : Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            5,
                                                                            5,
                                                                            5,
                                                                            5),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(AppLocalizations()
                                                                            .lbFil +
                                                                        ' $chch')
                                                                  ],
                                                                ),
                                                              )
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      displayBottomSheet(
                                                          context, citylist);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            activeSearchWare == true
                                                ? Expanded(
                                                    child: ListView.builder(
                                                    itemCount:
                                                        itemsWare.length + 1,
                                                    // Add one more item for progress indicator
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      if (index ==
                                                          itemsWare.length) {
                                                        return _buildProgressIndicatorWare();
                                                      } else {
                                                        return new Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  10, 5, 10, 5),
                                                          child:
                                                              GestureDetector(
                                                            child: Container(
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            10,
                                                                            0,
                                                                            10,
                                                                            0),
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              10,
                                                                              5,
                                                                              10,
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            itemsWare[index].Name.toString(),
                                                                            style: TextStyle(
                                                                                color: Colors.praimarydark,
                                                                                fontSize: 17,
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              10,
                                                                              0,
                                                                              10,
                                                                              15),
                                                                      child:
                                                                          Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            itemsWare[index].Addres.toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                image: AssetImage(
                                                                    'assets/images/storecard.png'),
                                                                fit:
                                                                    BoxFit.fill,
                                                              )),
                                                            ),
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                PageRouteBuilder(
                                                                  pageBuilder: (_, __, ___) => Directionality(
                                                                      textDirection: langSave ==
                                                                              'ar'
                                                                          ? TextDirection
                                                                              .rtl
                                                                          : TextDirection
                                                                              .ltr,
                                                                      child: storeDetails(
                                                                          itemsWare[index]
                                                                              .Name,
                                                                          itemsWare[index]
                                                                              .id)),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                        ;
                                                      }
                                                    },
                                                    controller: _scWare,
                                                  ))
                                                : tListallWare == null
                                                    ? Container()
                                                    : Expanded(
                                                        child: ListView.builder(
                                                        itemCount: tListallWare
                                                                .length +
                                                            1,
                                                        // Add one more item for progress indicator
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8.0),
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          if (index ==
                                                              tListallWare
                                                                  .length) {
                                                            return _buildProgressIndicatorWare();
                                                          } else {
                                                            return new Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          5,
                                                                          10,
                                                                          5),
                                                              child:
                                                                  GestureDetector(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            10,
                                                                            0,
                                                                            10,
                                                                            15),
                                                                    child:
                                                                        Column(
                                                                      children: <
                                                                          Widget>[
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              10,
                                                                              5,
                                                                              10,
                                                                              5),
                                                                          child:
                                                                              Row(
                                                                            children: <Widget>[
                                                                              Text(
                                                                                tListallWare[index].Name.toString(),
                                                                                style: TextStyle(color: Colors.praimarydark, fontSize: 17, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              10,
                                                                              0),
                                                                          child:
                                                                              Row(
                                                                            children: <Widget>[
                                                                              Text(
                                                                                tListallWare[index].Addres.toString(),
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/images/storecard.png'),
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  )),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(
                                                                    PageRouteBuilder(
                                                                      pageBuilder: (_, __, ___) => Directionality(
                                                                          textDirection: langSave == 'ar'
                                                                              ? TextDirection
                                                                                  .rtl
                                                                              : TextDirection
                                                                                  .ltr,
                                                                          child: storeDetails(
                                                                              tListallWare[index].Name,
                                                                              tListallWare[index].id)),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                            ;
                                                          }
                                                        },
                                                        controller: _scWare,
                                                      )),
                                          ],
                                        ),
                                      ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('error');
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.praimarydark),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    : Container(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: text == 'Home'
                    ? Image.asset('assets/images/homes.png')
                    : Image.asset('assets/images/homeicon.png'),
                title: text == 'Home'
                    ? Text(
                        AppLocalizations().lbHome,
                        style: TextStyle(color: Colors.praimarydark),
                      )
                    : Text(
                        AppLocalizations().lbHome,
                        style: TextStyle(color: Colors.grey),
                      )),
            BottomNavigationBarItem(
                icon: text == 'Store'
                    ? Image.asset('assets/images/stores.png')
                    : Image.asset('assets/images/store.png'),
                title: text == 'Store'
                    ? Text(
                        AppLocalizations().lbWare,
                        style: TextStyle(color: Colors.praimarydark),
                      )
                    : Text(
                        AppLocalizations().lbWare,
                        style: TextStyle(color: Colors.grey),
                      )),
            BottomNavigationBarItem(
                icon: text == 'Pharma'
                    ? Image.asset(
                        'assets/images/offerws.png',
                      )
                    : Image.asset('assets/images/offerh.png'),
                title: text == 'Pharma'
                    ? Text(
                        AppLocalizations().lbOffer,
                        style: TextStyle(color: Colors.praimarydark),
                      )
                    : Text(
                        AppLocalizations().lbOffer,
                        style: TextStyle(color: Colors.grey),
                      )),
            BottomNavigationBarItem(
                icon: text == 'Settings'
                    ? Image.asset('assets/images/mores.png')
                    : Image.asset('assets/images/morehome.png'),
                title: text == 'Settings'
                    ? Text(
                        AppLocalizations().lbOther,
                        style: TextStyle(color: Colors.praimarydark),
                      )
                    : Text(
                        AppLocalizations().lbOther,
                        style: TextStyle(color: Colors.grey),
                      )),
          ],
          onTap: _onTap,
        ),
      ),
      onWillPop: () async {
        // exit=0;
        if (exit == 0) {
          Toast.show(AppLocalizations().lbClick, context,
              duration: 4, gravity: Toast.BOTTOM);
          setState(() {
            exit = 1;
          });
        } else {
          return true;
          //  Navigator.pop(context,true);
          setState(() {
            exit = 0;
          });
        }
      },
    );
  }

  void _newTaskModalBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        builder: (BuildContext bc) {
          return Container(
            // color: Colors.red,
            // height: 200,
            // width: double.infinity,
            child: new Wrap(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(37, 20, 0, 40),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset('assets/images/drughome.png'),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        AppLocalizations().lbDrug,
                                        style: TextStyle(
                                          color: Colors.praimary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: langSave == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: durgsList()));
                                Navigator.pushReplacement(context, route);
                              },
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(37, 20, 0, 40),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset('assets/images/myreqhome.png'),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        AppLocalizations().lbReq,
                                        style:
                                            TextStyle(color: Colors.praimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: langSave == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: reqList()));
                                Navigator.pushReplacement(context, route);
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/pharmanew.png',
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        AppLocalizations().lbPharma,
                                        style:
                                            TextStyle(color: Colors.praimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: langSave == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: pharmaListP()));
                                Navigator.pushReplacement(context, route);
                              },
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset('assets/images/timer.png'),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        AppLocalizations().lbRem,
                                        style:
                                            TextStyle(color: Colors.praimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: langSave == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: reminderList()));
                                Navigator.pushReplacement(context, route);
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 37, 40),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                        'assets/images/compainhome.png'),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        AppLocalizations().lbCom,
                                        style:
                                            TextStyle(color: Colors.praimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: langSave == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: compainListPage()));
                                Navigator.pushReplacement(context, route);
                              },
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 37, 40),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                        'assets/images/settinghome.png'),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        AppLocalizations().lbSet,
                                        style:
                                            TextStyle(color: Colors.praimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: langSave == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: setting()));
                                Navigator.pushReplacement(context, route);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void displayBottomSheetPh(BuildContext context, List<City> citiee) {
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
                          color: Colors.transparent,
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
                        itemsOffer.clear();
                        citiee[index].check = true;
                        nameSearchPharma = citiee[index].cityName;
                        idcityPh = citiee[index].id.toString();
                        getValueString();
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }),
          );
        });
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
                          color: Colors.transparent,
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
                        itemsWare.clear();
                        citiee[index].check = true;
                        chch = citiee[index].cityName;
                        idcity = citiee[index].id.toString();
                        getValueString();
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }),
          );
        });
  }
}
