//import 'package:pharmas/Response/durgDetailsResponse.dart';


import 'package:pharmas/Repository/pharmaRepository.dart';
import 'package:pharmas/Response/pharmaResponse.dart';
import 'package:rxdart/rxdart.dart';

class pharmaBloc {
  final PharmaRepository _repository = PharmaRepository();
  final BehaviorSubject<PharmaResponse> _subject =
  BehaviorSubject<PharmaResponse>();
 /* final BehaviorSubject<durgDetailsResponse> _subjectDetails =
  BehaviorSubject<durgDetailsResponse>();*/


  getPharmaList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    PharmaResponse response = await _repository.gerPharmaList(sessionId,data,lang);
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

  BehaviorSubject<PharmaResponse> get subject => _subject;
 // BehaviorSubject<durgDetailsResponse> get subjectdetails => _subjectDetails;
}

final blocPharma= pharmaBloc();