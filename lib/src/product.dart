class EmmaProduct {
  String productId;
  String productName;
  int quantity;
  double price;
  //optional
  Map<String, String>? extras;

  EmmaProduct(this.productId, this.productName, this.quantity, this.price);

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "productName": productName,
      "quantity": quantity,
      "price": price,
      "extras": extras
    };
  }
}
