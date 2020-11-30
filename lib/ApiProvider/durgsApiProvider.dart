import 'package:dio/dio.dart';
import 'package:pharmas/Response/cityResponse.dart';
import 'package:pharmas/Response/durgsResponse.dart';
import 'package:pharmas/Response/durgDetailsResponse.dart';

class DurgsApiProvider {
  Dio _dio = Dio();

  DurgsApiProvider() {
    _dio.interceptors.clear();
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      // Do something before request is sent
      options.headers["Content-Type"] = "application/json";
      return options;
    }, onResponse: (Response response) {
      // Do something with response data
      return response; // continue
    }, onError: (DioError error) async {
      // Do something with response error
      if (error.response?.statusCode == 403) {
        _dio.interceptors.requestLock.lock();
        _dio.interceptors.responseLock.lock();
        RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
        options.headers["Content-Type"] = "application/json";

        _dio.interceptors.requestLock.unlock();
        _dio.interceptors.responseLock.unlock();
        return _dio.request(options.path, options: options);
      } else {
        return error;
      }
    }));
  }

  String _handleError(DioError error) {
    String errorDescription = "";
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.CANCEL:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          errorDescription = "Connection timeout with API server";
          break;
        case DioErrorType.DEFAULT:
          errorDescription =
              "Connection to API server failed due to internet connection";
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorDescription = "Receive timeout in connection with API server";
          break;
        case DioErrorType.RESPONSE:
          "${error.response.data['message']}";
          break;
//        case DioErrorType.SEND_TIMEOUT:
//          errorDescription =
//              "Send Request to Server Timeout: ${error.response.statusCode}";
          break;
      }
    } else {
      errorDescription = "Unexpected error occured";
    }
    return errorDescription;
  }
  Future<CityResponse> getCategoryList(String lang) async {
    Response response;
    try {

      _dio.interceptors.clear();
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        // Do something before request is sent
        options.headers["Content-Type"] = "application/json" ;
        options.headers["Accept-Language"] = lang;

        return options;
      }, onResponse: (Response response) {
        // Do something with response data
        return response; // continue
      }, onError: (DioError error) async {
        // Do something with response error
        if (error.response?.statusCode == 403) {
          _dio.interceptors.requestLock.lock();
          _dio.interceptors.responseLock.lock();
          RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
          options.headers["Content-Type"] = "application/json" ;
          options.headers["Accept-Language"] = lang;

          _dio.interceptors.requestLock.unlock();
          _dio.interceptors.responseLock.unlock();
          return _dio.request(options.path, options: options);
        } else {
          return error;
        }
      }));
      response = await _dio.post('http://api.mypharma-order.com:8080/APIS/api/Listing/GetCategoriesList');
      print(response);
      return CityResponse.fromJson(response.data);


    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return CityResponse.withError(_handleError(error));

    }
  }

  Future<DurgsResponse> getDurgsList(String sessionId,Map<String, dynamic> data,String lang) async {
    Response response;
    try {
      _dio.interceptors.clear();
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        // Do something before request is sent
        options.headers["Content-Type"] = "application/json";
        options.headers["Session-ID"] = sessionId;
        options.headers["Accept-Language"] = lang;

        return options;
      }, onResponse: (Response response) {
        // Do something with response data
        return response; // continue
      }, onError: (DioError error) async {
        // Do something with response error
        if (error.response?.statusCode == 403) {
          _dio.interceptors.requestLock.lock();
          _dio.interceptors.responseLock.lock();
          RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
          options.headers["Content-Type"] = "application/json";
          options.headers["Session-ID"] = sessionId;
          options.headers["Accept-Language"] = lang;

          _dio.interceptors.requestLock.unlock();
          _dio.interceptors.responseLock.unlock();
          return _dio.request(options.path, options: options);
        } else {
          return error;
        }
      }));
      print(data);
      print(sessionId);
      response = await _dio.post(
          "http://api.mypharma-order.com:8080/APIS/api/Drugs/GetDrugsList",data: data);
      print(response);
      return DurgsResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return DurgsResponse.withError(_handleError(error));
    }
  }

  Future<durgDetailsResponse> getDurgDetails(String sessionId,Map<String, dynamic> data,String lang) async {
    Response response;
    try {
      _dio.interceptors.clear();
      _dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        // Do something before request is sent
        options.headers["Content-Type"] = "application/json";
        options.headers["Session-ID"] = sessionId;
        options.headers["Accept-Language"] = lang;

        return options;
      }, onResponse: (Response response) {
        // Do something with response data
        return response; // continue
      }, onError: (DioError error) async {
        // Do something with response error
        if (error.response?.statusCode == 403) {
          _dio.interceptors.requestLock.lock();
          _dio.interceptors.responseLock.lock();
          RequestOptions options = error.response.request;
//          FirebaseUser user = await FirebaseAuth.instance.currentUser();
//          token = await user.getIdToken(refresh: true);
//          await writeAuthKey(token);
          options.headers["Content-Type"] = "application/json";
          options.headers["Session-ID"] = sessionId;
          options.headers["Accept-Language"] = lang;

          _dio.interceptors.requestLock.unlock();
          _dio.interceptors.responseLock.unlock();
          return _dio.request(options.path, options: options);
        } else {
          return error;
        }
      }));
      response = await _dio.post(
          "http://api.mypharma-order.com:8080/APIS/api/Drugs/GetDrugDetails",data: data);
      return durgDetailsResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return durgDetailsResponse.withError(_handleError(error));
    }
  }


}



