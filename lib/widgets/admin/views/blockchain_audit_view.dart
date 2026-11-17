// lib/widgets/admin/views/blockchain_audit_view.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';

class BlockchainAuditView extends StatelessWidget {
  const BlockchainAuditView({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = AdminManager.instance;
    final blocks = admin.blockchainBlocks;
    final status = admin.blockchainStatus;
    final isValid = status['isValid'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Banner Integritas
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isValid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isValid ? const Color(0xFF81C784) : const Color(0xFFE57373),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isValid ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isValid ? Icons.verified_user : Icons.gpp_bad,
                  color: isValid ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isValid ? 'INTEGRITAS DATABASE & RANTAI BLOK 100% VALID' : 'PERINGATAN INTEGRITAS',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isValid ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isValid ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ANTI-TAMPER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status['message']?.toString() ?? 'Seluruh riwayat perubahan hak akses dan verifikasi pengantaran terkunci kekal dengan hash SHA-256.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isValid ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => admin.auditBlockchainIntegrity(),
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Verifikasi Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Buku Besar Kriptografi (Immutable SHA-256 Chained Blocks)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
            ),
            Text(
              'Total Blok: ${blocks.length}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.caramel),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Blockchain Blocks Chaining View
        Expanded(
          child: blocks.isEmpty
              ? const Center(child: Text('Belum ada blok yang tercatat.'))
              : ListView.separated(
                  itemCount: blocks.length,
                  separatorBuilder: (_, _) => Center(
                    child: Container(
                      width: 2,
                      height: 16,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final b = blocks[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Block Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.espresso,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'BLOK #${b.blockIndex}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    b.eventLabel,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.espresso),
                                  ),
                                ],
                              ),
                              Text(
                                '${b.timestamp.day}/${b.timestamp.month}/${b.timestamp.year} ${b.timestamp.hour.toString().padLeft(2, '0')}:${b.timestamp.minute.toString().padLeft(2, '0')} WIB',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Cryptographic Hash Data
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHashRow('Previous Hash:', b.previousHash),
                                const SizedBox(height: 4),
                                _buildHashRow('Current Block Hash:', b.blockHash, isHighlighted: true),
                                const SizedBox(height: 4),
                                _buildHashRow('Payload SHA-256:', b.payloadHash),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHashRow(String label, String hash, {bool isHighlighted = false}) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? const Color(0xFF2E7D32) : AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            hash,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
              color: isHighlighted ? const Color(0xFF1B5E20) : AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
