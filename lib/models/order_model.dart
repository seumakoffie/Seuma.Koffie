// lib/models/order_model.dart
import 'dart:math';

String generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // Version 4
  values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xx
  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}

enum OrderStatus {
  pending,
  brewing,
  readyForDelivery,
  onDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'brewing':
        return OrderStatus.brewing;
      case 'ready_for_delivery':
      case 'ready':
        return OrderStatus.readyForDelivery;
      case 'on_delivery':
      case 'delivering':
        return OrderStatus.onDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String get dbValue {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.brewing:
        return 'brewing';
      case OrderStatus.readyForDelivery:
        return 'ready_for_delivery';
      case OrderStatus.onDelivery:
        return 'on_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu Konfirmasi';
      case OrderStatus.brewing:
        return 'Sedang Diseduh';
      case OrderStatus.readyForDelivery:
        return 'Siap Diantar';
      case OrderStatus.onDelivery:
        return 'Dalam Pengantaran';
      case OrderStatus.delivered:
        return 'Tiba di Lokasi & Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get badgeEmoji {
    switch (this) {
      case OrderStatus.pending:
        return '🟡';
      case OrderStatus.brewing:
        return '☕';
      case OrderStatus.readyForDelivery:
        return '📦';
      case OrderStatus.onDelivery:
        return '🛵';
      case OrderStatus.delivered:
        return '✅';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}

enum PaymentMethod {
  qris,
  cod,
  transferBank;

  static PaymentMethod fromString(String? method) {
    switch (method?.toLowerCase()) {
      case 'cod':
        return PaymentMethod.cod;
      case 'transfer_bank':
      case 'transfer':
        return PaymentMethod.transferBank;
      case 'qris':
      default:
        return PaymentMethod.qris;
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentMethod.qris:
        return 'qris';
      case PaymentMethod.cod:
        return 'cod';
      case PaymentMethod.transferBank:
        return 'transfer_bank';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.qris:
        return 'QRIS Instant';
      case PaymentMethod.cod:
        return 'Bayar di Tempat (COD)';
      case PaymentMethod.transferBank:
        return 'Transfer Bank';
    }
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String menuId;
  final String menuName;
  final String? variant;
  final double price;
  final int quantity;
  final double subtotal;
  final String? specialNotes;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.menuName,
    this.variant,
    required this.price,
    this.quantity = 1,
    required this.subtotal,
    this.specialNotes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'menu_id': menuId,
    'menu_name': menuName,
    'variant': variant,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
    'special_notes': specialNotes,
  };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      menuName: json['menu_name']?.toString() ?? 'Kopi Sanger',
      variant: json['variant']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      specialNotes: json['special_notes']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? userId;
  final double totalAmount;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String paymentStatus;

  // Alamat & Penerima (Lhokseumawe & Sekitarnya)
  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final String? deliveryNotes;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? mapsUrl;

  // Verifikasi Pengantaran di Lokasi
  final String? verifiedBy;
  final String? deliveryProofUrl;
  final String? deliveryVerificationHash;
  final DateTime? deliveredAt;

  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.paymentMethod = PaymentMethod.cod,
    this.paymentStatus = 'unpaid',
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    this.deliveryNotes,
    this.deliveryLat,
    this.deliveryLng,
    this.mapsUrl,
    this.verifiedBy,
    this.deliveryProofUrl,
    this.deliveryVerificationHash,
    this.deliveredAt,
    required this.createdAt,
    this.items = const [],
  });

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    double? totalAmount,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? paymentStatus,
    String? recipientName,
    String? recipientPhone,
    String? deliveryAddress,
    String? deliveryNotes,
    double? deliveryLat,
    double? deliveryLng,
    String? mapsUrl,
    String? verifiedBy,
    String? deliveryProofUrl,
    String? deliveryVerificationHash,
    DateTime? deliveredAt,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      deliveryProofUrl: deliveryProofUrl ?? this.deliveryProofUrl,
      deliveryVerificationHash: deliveryVerificationHash ?? this.deliveryVerificationHash,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'user_id': userId,
    'total_amount': totalAmount,
    'status': status.dbValue,
    'payment_method': paymentMethod.dbValue,
    'payment_status': paymentStatus,
    'recipient_name': recipientName,
    'recipient_phone': recipientPhone,
    'delivery_address': deliveryAddress,
    'delivery_notes': deliveryNotes,
    'delivery_lat': deliveryLat,
    'delivery_lng': deliveryLng,
    if (mapsUrl != null) 'maps_url': mapsUrl,
    'verified_by': verifiedBy,
    'delivery_proof_url': deliveryProofUrl,
    'delivery_verification_hash': deliveryVerificationHash,
    'delivered_at': deliveredAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json, {List<OrderItemModel> items = const []}) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? 'SEUMA-000',
      userId: json['user_id']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(json['status']?.toString()),
      paymentMethod: PaymentMethod.fromString(json['payment_method']?.toString()),
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      recipientName: json['recipient_name']?.toString() ?? 'Pelanggan',
      recipientPhone: json['recipient_phone']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? 'Lhokseumawe',
      deliveryNotes: json['delivery_notes']?.toString(),
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      mapsUrl: json['maps_url']?.toString(),
      verifiedBy: json['verified_by']?.toString(),
      deliveryProofUrl: json['delivery_proof_url']?.toString(),
      deliveryVerificationHash: json['delivery_verification_hash']?.toString(),
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      items: items,
    );
  }
}
