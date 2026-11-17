// lib/models/blockchain_block_model.dart

class BlockchainBlockModel {
  final int blockIndex;
  final DateTime timestamp;
  final String eventType; // 'GENESIS_BLOCK', 'USER_REGISTERED', 'ROLE_PROMOTED', 'ORDER_DELIVERED_VERIFIED'
  final String? actorId;
  final String recordId;
  final String payloadHash;
  final String previousHash;
  final String blockHash;
  final int nonce;

  const BlockchainBlockModel({
    required this.blockIndex,
    required this.timestamp,
    required this.eventType,
    this.actorId,
    required this.recordId,
    required this.payloadHash,
    required this.previousHash,
    required this.blockHash,
    this.nonce = 0,
  });

  String get eventLabel {
    switch (eventType) {
      case 'GENESIS_BLOCK':
        return '🌱 Genesis Block (Awal Sistem)';
      case 'USER_REGISTERED':
        return '👤 Registrasi Konsumen Baru';
      case 'ROLE_PROMOTED':
        return '🔐 Promosi Akses (Role Change)';
      case 'ORDER_DELIVERED_VERIFIED':
        return '✅ Verifikasi Pengantaran Pesanan';
      default:
        return '⛓️ $eventType';
    }
  }

  String get shortBlockHash => blockHash.length > 16 
      ? '${blockHash.substring(0, 8)}...${blockHash.substring(blockHash.length - 8)}' 
      : blockHash;

  String get shortPrevHash => previousHash.length > 16 
      ? '${previousHash.substring(0, 8)}...${previousHash.substring(previousHash.length - 8)}' 
      : previousHash;

  factory BlockchainBlockModel.fromJson(Map<String, dynamic> json) {
    return BlockchainBlockModel(
      blockIndex: (json['block_index'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      eventType: json['event_type']?.toString() ?? 'GENERIC_EVENT',
      actorId: json['actor_id']?.toString(),
      recordId: json['record_id']?.toString() ?? '',
      payloadHash: json['payload_hash']?.toString() ?? '',
      previousHash: json['previous_hash']?.toString() ?? '',
      blockHash: json['block_hash']?.toString() ?? '',
      nonce: (json['nonce'] as num?)?.toInt() ?? 0,
    );
  }
}
