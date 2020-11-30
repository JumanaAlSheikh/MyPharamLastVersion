

import 'package:pharmas/Repository/OrderRepository.dart';
import 'package:pharmas/Response/requestResponse.dart';
import 'package:rxdart/rxdart.dart';

class orderBloc {
  final OrderRepository _repository = OrderRepository();
  final BehaviorSubject<reqResponse> _subject =
  BehaviorSubject<reqResponse>();
  /* final BehaviorSubject<durgDetailsResponse> _subjectDetails =
  BehaviorSubject<durgDetailsResponse>();*/


  getOrderList(String sessionId,Map<String, dynamic> data,String lang) async {
    print("before get the get med resonse");

    reqResponse response = await _repository.getOrderList(sessionId,data,lang);
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

  BehaviorSubject<reqResponse> get subject => _subject;
// BehaviorSubject<durgDetailsResponse> get subjectdetails => _subjectDetails;
}

final blocOrder= orderBloc();