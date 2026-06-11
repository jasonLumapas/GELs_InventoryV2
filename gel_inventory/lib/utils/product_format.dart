import '../models/product.dart';

const _unitAlternation = 'ml|ltrs?|l|kg|g|oz|cl|gal|lbs?';

final RegExp _packagingUnitPattern =
    RegExp(r'^\d+(\.\d+)?(' '$_unitAlternation' r')$', caseSensitive: false);

// e.g. "12x1ltr" -> captures "1ltr"
final RegExp _multiPackPattern = RegExp(
    r'^\d+x(\d+(\.\d+)?(' '$_unitAlternation' r'))$',
    caseSensitive: false);

/// Returns e.g. "24 x 500ml" or just "24" if no volume/weight unit token is
/// found anywhere in the product name. Searches from the end of the name so
/// that trailing descriptors (e.g. "w/HANDLE") don't hide the unit.
String packagingLabel(Product product) {
  final tokens = product.name.trim().split(RegExp(r'\s+'));
  for (final token in tokens.reversed) {
    final multiMatch = _multiPackPattern.firstMatch(token);
    if (multiMatch != null) {
      return '${product.piecesPerBox} x ${multiMatch.group(1)}';
    }
    if (_packagingUnitPattern.hasMatch(token)) {
      return '${product.piecesPerBox} x $token';
    }
  }
  return '${product.piecesPerBox}';
}
