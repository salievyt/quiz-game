abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server Error']);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = 'No Internet Connection']);
}

class AuthFailure extends Failure {
  AuthFailure([super.message = 'Authentication failed']);
}

class UnknownFailure extends Failure {
  UnknownFailure([super.message = 'An unknown error occurred']);
}
