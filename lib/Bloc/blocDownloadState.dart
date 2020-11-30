import 'dart:async';

import 'package:pharmas/Bloc/blocWare.dart';
import 'package:pharmas/Repository/WareRepository.dart';
import 'package:pharmas/Response/WareResponse.dart';
import 'package:pharmas/Response/storeDetailsResponse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';



class blocStateDee {
  final StreamController controller = StreamController<DownloadState>.broadcast();
  Stream get dataState => controller.stream; // exposing your stream output

  final WareRepository _repository = WareRepository();
  final BehaviorSubject<WareResponse> _subject =
  BehaviorSubject<WareResponse>();
  final BehaviorSubject<storeDetailsResponse> _subjectDetails =
  BehaviorSubject<storeDetailsResponse>();
  void _changeState( final DownloadState state ) => controller.sink.add( state );

  void downloadData(String sessionId,Map<String, dynamic> data,String lang){
    _changeState( DownloadState.DOWNLOADING );
    // assuming that this call returns a Future object.
    getStoreDetails( sessionId,data,lang).then(  (yourNetworkData) {
      // handle your downloaded data
      _changeState( DownloadState.SUCCESS );
    }  ).catchError( (apiError) =>  controller.sink.addError( apiError ) );
  }


  getStoreDetails(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    storeDetailsResponse response = await _repository.getStoreDetails(sessionId,data,lang);
    _subjectDetails.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }
  BehaviorSubject<storeDetailsResponse> get subjectdetails => _subjectDetails;
}enum DownloadState { NO_DOWNLOAD,  DOWNLOADING, SUCCESS }
final blocStateDe = blocStateDee();