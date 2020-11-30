//import 'package:pharmas/Response/durgDetailsResponse.dart';


import 'package:pharmas/Repository/compainRepository.dart';
import 'package:pharmas/Response/CompainResponse.dart';
import 'package:rxdart/rxdart.dart';

class compainBloc {
  final CompainRepository _repository = CompainRepository();
  final BehaviorSubject<CompainResponse> _subject =
  BehaviorSubject<CompainResponse>();
  /* final BehaviorSubject<durgDetailsResponse> _subjectDetails =
  BehaviorSubject<durgDetailsResponse>();*/


  getCompainList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    CompainResponse response = await _repository.getcompainList(sessionId,data,lang);
    _subject.sink.add(response);

  //  print("after get the get med resonse \n ${response.results}");


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

  BehaviorSubject<CompainResponse> get subject => _subject;
// BehaviorSubject<durgDetailsResponse> get subjectdetails => _subjectDetails;
}

final blocCompain= compainBloc();