class DeliveryAddress {
  const DeliveryAddress({
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.number,
    this.complement,
  });

  final String state;
  final String city;
  final String neighborhood;
  final String street;
  final String number;
  final String? complement;

  Map<String, dynamic> toJson() => {
        'state': state,
        'city': city,
        'neighborhood': neighborhood,
        'street': street,
        'number': number,
        if (complement != null) 'complement': complement,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        state: json['state'] as String,
        city: json['city'] as String,
        neighborhood: json['neighborhood'] as String,
        street: json['street'] as String,
        number: json['number'] as String,
        complement: json['complement'] as String?,
      );

  String get formatted =>
      '$street, $number'
      '${complement != null ? ', $complement' : ''} — '
      '$neighborhood, $city/$state';
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.skuId,
    required this.quantity,
    required this.unitPrice,
    this.skuName,
    this.productName,
  });

  final String id;
  final String orderId;
  final String skuId;
  final int quantity;
  final double unitPrice;
  final String? skuName;
  final String? productName;

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        skuId: json['sku_id'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unit_price'] as num).toDouble(),
        skuName: (json['skus'] as Map<String, dynamic>?)?['name'] as String?,
        productName: ((json['skus'] as Map<String, dynamic>?)?['products']
            as Map<String, dynamic>?)?['name'] as String?,
      );
}

class Order {
  const Order({
    required this.id,
    required this.customerId,
    required this.deliveryDate,
    required this.deliveryAddress,
    required this.paymentStatus,
    required this.productionStatus,
    required this.total,
    required this.createdAt,
    this.stripePaymentIntentId,
    this.items = const [],
    this.customerName,
    this.customerPhone,
  });

  final String id;
  final String customerId;
  final DateTime deliveryDate;
  final DeliveryAddress deliveryAddress;
  final String paymentStatus;
  final String productionStatus;
  final double total;
  final DateTime createdAt;
  final String? stripePaymentIntentId;
  final List<OrderItem> items;
  final String? customerName;
  final String? customerPhone;

  bool get isPaid => paymentStatus == 'paid';

  static const productionStatuses = [
    'aguardando',
    'em_producao',
    'pronto',
    'saiu_entrega',
    'entregue',
  ];

  static const productionStatusLabels = {
    'aguardando': 'Aguardando',
    'em_producao': 'Em produção',
    'pronto': 'Pronto',
    'saiu_entrega': 'Saiu para entrega',
    'entregue': 'Entregue',
  };

  String? get nextStatus {
    final idx = productionStatuses.indexOf(productionStatus);
    if (idx < 0 || idx >= productionStatuses.length - 1) return null;
    return productionStatuses[idx + 1];
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final customer = json['customers'] as Map<String, dynamic>?;
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      deliveryDate: DateTime.parse(json['delivery_date'] as String),
      deliveryAddress: DeliveryAddress.fromJson(
          json['delivery_address'] as Map<String, dynamic>),
      paymentStatus: json['payment_status'] as String,
      productionStatus: json['production_status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      stripePaymentIntentId:
          json['stripe_payment_intent_id'] as String?,
      items: rawItems
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerName: customer?['name'] as String?,
      customerPhone: customer?['phone'] as String?,
    );
  }
}
