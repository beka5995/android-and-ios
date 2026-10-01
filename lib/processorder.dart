double processOrder({
    required String orderId,
    required double itemPrice,
    String? promoCode,
    double? deliveryFee,
  }) {
    double finalDelivery = deliveryFee ?? 2000.0;

    if(finalDelivery < 2000){
      finalDelivery = 2000;
    }

    double finalPrice = itemPrice;
    if (promoCode == 'SAVE10') {
      finalPrice = itemPrice * 0.9;
    }

    double total = finalPrice + finalDelivery;
    
    print('Order ID: $orderId');
    print('Item Price: $itemPrice ₸');
    if (promoCode != null) print('Promo Code: $promoCode (Applied)');
    print('Delivery Fee: $finalDelivery ₸');
    print('Final Total: $total ₸\n');

    return total;
  }

  void main() {
    processOrder(
      orderId: 'ORD-001',
      itemPrice: 5000.0,
      promoCode: 'SAVE10',
    );

    processOrder(
      orderId: 'ORD-002',
      itemPrice: 10000.0,
      deliveryFee: 1000.0,
    );
}