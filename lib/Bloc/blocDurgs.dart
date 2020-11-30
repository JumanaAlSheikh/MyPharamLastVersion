import 'dart:async';

import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/durgDetailsResponse.dart';


import 'package:pharmas/Repository/durgsrepository.dart';
import 'package:pharmas/Response/durgsResponse.dart';
import 'package:rxdart/rxdart.dart';

class durgsBloc {
  final DurgsRepository _repository = DurgsRepository();
  final BehaviorSubject<DurgsResponse> _subject =
  BehaviorSubject<DurgsResponse>();
  final BehaviorSubject<durgDetailsResponse> _subjectDetails =
  BehaviorSubject<durgDetailsResponse>();
  final StreamController controller = StreamController<DownloadState>.broadcast();
  Stream get dataState => controller.stream; // exposing your stream output

  final BehaviorSubject<CityResponse> _subjectCat =
  BehaviorSubject<CityResponse>();


  void _changeState( final DownloadState state ) => controller.sink.add( state );

  void downloadData(String sessionId,Map<String, dynamic> data,String lang){
    _changeState( DownloadState.DOWNLOADING );
    // assuming that this call returns a Future object.
    getDurgsDetails( sessionId,data,lang).then(  (yourNetworkData) {
      // handle your downloaded data
      _changeState( DownloadState.SUCCESS );
    }  ).catchError( (apiError) =>  controller.sink.addError( apiError ) );
  }



  getDurgsList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    DurgsResponse response = await _repository.getDurgsLisy(sessionId,data,lang);
    _subject.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }

  getCategoryList(String lang) async {
    print("before get the get med resonse");

    CityResponse response = await _repository.getCategoryList(lang);
    _subjectCat.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }

  getDurgsDetails(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    durgDetailsResponse response = await _repository.getDurgDetails(sessionId,data,lang);
    _subjectDetails.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }


  dispose() {
    _subject.close();
    _subjectDetails.close();
    _subjectCat.close();
  }

  BehaviorSubject<DurgsResponse> get subject => _subject;
BehaviorSubject<durgDetailsResponse> get subjectdetails => _subjectDetails;
  BehaviorSubject<CityResponse> get subjectCat => _subjectCat;

}
enum DownloadState { NO_DOWNLOAD,  DOWNLOADING, SUCCESS }
final blocDurgs= durgsBloc();