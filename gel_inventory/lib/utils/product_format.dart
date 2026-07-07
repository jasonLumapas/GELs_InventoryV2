import '../models/product.dart';

/// Returns e.g. "24 pcs/case".
String packagingLabel(Product product) => '${product.piecesPerBox} pcs/case';
