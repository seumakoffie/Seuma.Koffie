// lib/widgets/admin/views/admin_consumer_tab.dart
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';

class AdminConsumerTab extends StatefulWidget {
  const AdminConsumerTab({super.key});

  @override
  State<AdminConsumerTab> createState() => _AdminConsumerTabState();
}

class _AdminConsumerTabState extends State<AdminConsumerTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pastikan data konsumen selalu termuat saat tab dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AdminManager.instance.consumers.isEmpty) {
        AdminManager.instance.loadAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminManager.instance,
      builder: (context, _) {
        final admin = AdminManager.instance;
        final allConsumers = admin.consumers;

        final filtered = allConsumers.where((c) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.phone.contains(q);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.people_alt,
                    color: const Color(0xFF2E7D32),
                    label: 'Total Konsumen',
                    value: '${allConsumers.length} Pengguna',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFFE65100),
                    label: 'Status Keanggotaan',
                    value: 'Member Seuma',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.security,
                    color: const Color(0xFF1565C0),
                    label: 'Enkripsi Data',
                    value: '100% E2EE Aktif',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Cari nama konsumen, email, atau no. WhatsApp...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Consumer List
            Expanded(
              child: admin.isLoading && allConsumers.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.espresso),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty ? 'Belum ada konsumen terdaftar.' : 'Konsumen tidak ditemukan.',
                                style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final consumer = filtered[index];
                            return _buildConsumerCard(context, consumer);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerCard(BuildContext context, UserModel consumer) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Initial
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.caramel.withValues(alpha: 0.15),
            child: Text(
              consumer.name.isNotEmpty ? consumer.name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.espresso),
            ),
          ),
          const SizedBox(width: 14),

          // Consumer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        consumer.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.espresso),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB0BEC5)),
                      ),
                      child: const Text(
                        'Member',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF455A64),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      consumer.email,
                      style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      consumer.phone,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('🔒 E2EE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points & Quick Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.caramel.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '⭐ ${consumer.points} Poin',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.caramel),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Terdaftar: ${consumer.createdAt != null ? '${consumer.createdAt!.day}/${consumer.createdAt!.month}/${consumer.createdAt!.year}' : 'Baru'}',
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
