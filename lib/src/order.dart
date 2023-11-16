class EmmaOrder {
  String orderId;
  double totalPrice;
  String customerId;
  //optional
  String? currencyCode;
  String? coupon;
  Map<String, String>? extras;

  EmmaOrder(this.orderId, this.totalPrice, this.customerId);

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "totalPrice": totalPrice,
      "customerId": customerId,
      "currencyCode": currencyCode,
      "coupon": coupon,
      "extras": extras
    };
  }
}
