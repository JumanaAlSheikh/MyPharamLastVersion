import 'package:pharmas/Response/storeDetailsResponse.dart';


import 'package:pharmas/Repository/WareRepository.dart';
import 'package:pharmas/Response/WareResponse.dart';
import 'package:rxdart/rxdart.dart';

class wareBloc {
  final WareRepository _repository = WareRepository();
  final BehaviorSubject<WareResponse> _subject =
  BehaviorSubject<WareResponse>();
   final BehaviorSubject<storeDetailsResponse> _subjectDetails =
  BehaviorSubject<storeDetailsResponse>();


  getWareList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    WareResponse response = await _repository.getWareList(sessionId,data,lang);
    _subject.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }
  getStoreDetails(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    storeDetailsResponse response = await _repository.getStoreDetails(sessionId,data,lang);
    _subjectDetails.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }


  dispose() {
    _subject.close();
      _subjectDetails.close();
  }

  BehaviorSubject<WareResponse> get subject => _subject;
 BehaviorSubject<storeDetailsResponse> get subjectdetails => _subjectDetails;
}

final blocWare= wareBloc();