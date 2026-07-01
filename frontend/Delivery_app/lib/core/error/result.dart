import 'failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure l) ifLeft, R Function(T r) ifRight);

  T getOrThrow() {
    return fold(
      (l) => throw Exception(l.message), // In a real app we might throw the Failure itself or an AppException
      (r) => r,
    );
  }

  Result<R> map<R>(R Function(T) f) {
    return fold(
      (l) => Left<R>(l),
      (r) => Right<R>(f(r)),
    );
  }
}

class Left<T> extends Result<T> {
  final Failure failure;
  const Left(this.failure);

  @override
  R fold<R>(R Function(Failure l) ifLeft, R Function(T r) ifRight) {
    return ifLeft(failure);
  }
}

class Right<T> extends Result<T> {
  final T value;
  const Right(this.value);

  @override
  R fold<R>(R Function(Failure l) ifLeft, R Function(T r) ifRight) {
    return ifRight(value);
  }
}

// Helper typedef like `Either<Failure, T>`
typedef Either<L extends Failure, R> = Result<R>;
