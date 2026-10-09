import '../../orders/domain/order.dart';

/// Endereço de entrega salvo pelo cliente (padrão Casa/Trabalho/Outro).
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.number,
    this.complement,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String state;
  final String city;
  final String neighborhood;
  final String street;
  final String number;
  final String? complement;
  final bool isDefault;

  static const suggestedLabels = ['Casa', 'Trabalho', 'Outro'];

  String get formatted =>
      '$street, $number'
      '${complement != null && complement!.isNotEmpty ? ', $complement' : ''} — '
      '$neighborhood, $city/$state';

  /// Snapshot imutável usado no pedido — independe de futuras edições
  /// ou exclusão deste endereço salvo.
  DeliveryAddress toDeliveryAddress() => DeliveryAddress(
        state: state,
        city: city,
        neighborhood: neighborhood,
        street: street,
        number: number,
        complement: complement,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        label: json['label'] as String,
        state: json['state'] as String,
        city: json['city'] as String,
        neighborhood: json['neighborhood'] as String,
        street: json['street'] as String,
        number: json['number'] as String,
        complement: json['complement'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
      );
}
