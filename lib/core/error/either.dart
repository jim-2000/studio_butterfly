/// Minimal `Either` — deliberately hand-rolled instead of pulling in a
/// functional-programming package for one type. `Left` carries a [Failure],
/// `Right` carries the success value; repositories return
/// `Future<Either<Failure, T>>` so callers can never forget the error case.
sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) => onLeft(value);
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) => onRight(value);
}
