class AppException implements Exception {
  final String? _prefix;
  final String? _message;

  AppException([this._prefix, this._message]);
  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class InternetException extends AppException {
  InternetException([String? message]) : super(message, 'Network Error');
}

class RequestTimeOut extends AppException {
  RequestTimeOut([String? message])
      : super(message, 'The Request Has Timed Out!');
}

class ServerError extends AppException {
  ServerError([String? message])
      : super(message, 'An Internal Server Error Occured');
}

class InvalidUrlException extends AppException {
  InvalidUrlException([String? message])
      : super(message, 'The Url Provided Is Invalid');
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, 'Failed To Fetch Data From The Server');
}
