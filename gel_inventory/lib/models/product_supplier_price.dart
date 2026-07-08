/// Supplier's price for a product, keyed one-to-one on productId (matching
/// the product's currently assigned supplier).
class ProductSupplierPrice {
  final String id;
  final String productId;
  final double priceBox;
  // Cascading discount percentages applied (in order) to priceBox,
  // e.g. [10, 5] = 10% off, then 5% off the result.
  final List<double> discountPercents;
  final bool vatEnabled; // applies 12% VAT on top of the discounted price

  const ProductSupplierPrice({
    required this.id,
    required this.productId,
    required this.priceBox,
    this.discountPercents = const [],
    this.vatEnabled = false,
  });

  /// Decodes the comma-separated "discount_percents" column, e.g. "10,5".
  static List<double> decodeDiscountPercents(String? raw) =>
      (raw == null || raw.isEmpty)
          ? const []
          : raw.split(',').map((s) => double.parse(s)).toList();

  /// Encodes a discount list back to the comma-separated storage format.
  static String? encodeDiscountPercents(List<double> discounts) =>
      discounts.isEmpty ? null : discounts.map((d) => d.toString()).join(',');

  factory ProductSupplierPrice.fromJson(Map<String, dynamic> j) =>
      ProductSupplierPrice(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        priceBox: (j['price_box'] as num).toDouble(),
        discountPercents:
            decodeDiscountPercents(j['discount_percents'] as String?),
        vatEnabled: (j['vat_enabled'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'price_box': priceBox,
        'discount_percents': encodeDiscountPercents(discountPercents),
        'vat_enabled': vatEnabled,
      };
}
