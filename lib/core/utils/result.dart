import 'package:quiz/core/error/failures.dart';

class Result<T> {
  final T? data;
  final Failure? error;

  Result._({this.data, this.error});

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(Failure error) => Result._(error: error);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
  
  void fold(void Function(Failure error) onFailure, void Function(T data) onSuccess) {
    if (isFailure) {
      onFailure(error!);
    } else {
      onSuccess(data as T);
    }
  }
}
