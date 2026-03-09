import 'purchase_product.dart';

class EmmaPurchaseRequest {
  String id;
  double totalPrice;
  List<EmmaPurchaseProduct> products;
  String? customerId;
  String? coupon;
  Map<String, String>? extras;

  EmmaPurchaseRequest(this.id, this.totalPrice, this.products);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "totalPrice": totalPrice,
      "products": products.map((product) => product.toMap()).toList(),
      "customerId": customerId,
      "coupon": coupon,
      "extras": extras,
    };
  }
}
