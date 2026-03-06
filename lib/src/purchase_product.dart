class EmmaPurchaseProduct {
  String id;
  String name;
  double qty;
  double price;
  Map<String, String>? extras;

  EmmaPurchaseProduct(this.id, this.name, this.qty, this.price);

  Map<String, dynamic> toMap() {
    return {
      "productId": id,
      "productName": name,
      "quantity": qty,
      "price": price,
      "extras": extras
    };
  }
}
