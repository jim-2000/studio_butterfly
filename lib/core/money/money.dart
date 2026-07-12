import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class Money extends Equatable {
  const Money(this.amount, this.currency);

  factory Money.parse(String amount, String currency) => Money(Decimal.parse(amount), currency);

  factory Money.zero(String currency) => Money(Decimal.zero, currency);

  final Decimal amount;
  final String currency;

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add $currency to ${other.currency}');
    return Money(amount + other.amount, currency);
  }

  Money operator *(int factor) => Money(amount * Decimal.fromInt(factor), currency);

  bool operator >(Money other) => amount > other.amount;

  bool get isZero => amount == Decimal.zero;

  /// Raw decimal string suitable for round-tripping back through the API
  /// (never a formatted/localized string).
  String toApiString() => amount.toString();

  /// Display string, e.g. `€12.45`. Always shows at least 2 decimal places
  /// and preserves extra precision (up to 4dp) rather than rounding it away.
  String get display {
    final places = amount.scale.clamp(2, 4);
    return '${_symbolFor(currency)}${amount.toStringAsFixed(places)}';
  }

  static String _symbolFor(String currency) => switch (currency) {
    'EUR' => '€',
    'USD' => r'$',
    'GBP' => '£',
    _ => '$currency ',
  };

  @override
  List<Object?> get props => [amount, currency];

  @override
  String toString() => display;
}
