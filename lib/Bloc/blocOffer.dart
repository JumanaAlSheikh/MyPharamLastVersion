//import 'package:pharmas/Response/durgDetailsResponse.dart';


import 'package:pharmas/Repository/offerRepository.dart';
import 'package:pharmas/Response/offerResponse.dart';
import 'package:rxdart/rxdart.dart';

class offerBloc {
  final offerRepository _repository = offerRepository();
  final BehaviorSubject<offerResponse> _subject =
  BehaviorSubject<offerResponse>();
  /* final BehaviorSubject<durgDetailsResponse> _subjectDetails =
  BehaviorSubject<durgDetailsResponse>();*/


  getOfferList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    offerResponse response = await _repository.getOfferList(sessionId,data,lang);
    _subject.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }
/*  getDurgsDetails(String sessionId,Map<String, dynamic> data) async {
    print("before get the get med resonse");

    durgDetailsResponse response = await _repository.getDurgDetails(sessionId,data);
    _subjectDetails.sink.add(response);

    print("after get the get med resonse \n ${response.results}");


  }*/


  dispose() {
    _subject.close();
    //  _subjectDetails.close();
  }

  BehaviorSubject<offerResponse> get subject => _subject;
// BehaviorSubject<durgDetailsResponse> get subjectdetails => _subjectDetails;
}

final blocOffer= offerBloc();