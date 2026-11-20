// lib/widgets/admin/views/admin_menu_management_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/menu_item.dart';
import '../../../state/auth_state.dart';
import '../../../state/menu_state.dart';
import '../../../theme/app_theme.dart';

class AdminMenuManagementTab extends StatefulWidget {
  const AdminMenuManagementTab({super.key});

  @override
  State<AdminMenuManagementTab> createState() => _AdminMenuManagementTabState();
}

class _AdminMenuManagementTabState extends State<AdminMenuManagementTab> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Espresso',
    'Kopi Americano',
    'Kopi Sanger',
    'Kopi Susu',
    'Matcha',
    'Squash',
    'Kopi Saku 200ml',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager.instance;
    final isSuperAdmin = auth.isSuperAdmin;

    return ListenableBuilder(
      listenable: MenuManager.instance,
      builder: (context, _) {
        final allItems = MenuManager.instance.items;
        final filteredItems = allItems.where((item) {
          final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == 'Semua' || item.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Action Toolbar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.caramel.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.caramel, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Katalog Menu & Kontrol Harga Realtime',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.espresso),
                                ),
                                Text(
                                  'Total ${allItems.length} menu terdaftar di database',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Super Admin Security Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSuperAdmin
                                ? Colors.green.shade50
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSuperAdmin ? Colors.green.shade300 : Colors.amber.shade400,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuperAdmin ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                                size: 14,
                                color: isSuperAdmin ? Colors.green.shade700 : Colors.amber.shade800,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isSuperAdmin
                                    ? '👑 Super Admin: Hak Akses Ubah Harga Aktif'
                                    : '🔒 Read-Only: Khusus Super Admin',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSuperAdmin ? Colors.green.shade800 : Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Search & Category Chips Row
                    Row(
                      children: [
                        // Search Field
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: const TextStyle(fontSize: 12.5),
                              decoration: const InputDecoration(
                                hintText: 'Cari nama menu / kategori...',
                                hintStyle: TextStyle(fontSize: 12, color: Colors.black45),
                                prefixIcon: Icon(Icons.search, size: 18, color: Colors.black45),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Category Dropdown Filter
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isDense: true,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.espresso),
                                items: _categories.map((c) {
                                  return DropdownMenuItem(value: c, child: Text(c));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCategory = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Menu List Table ─────────────────────────────────────────────
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'Menu tidak ditemukan',
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildMenuItemRow(context, item, isSuperAdmin);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItemRow(BuildContext context, MenuItem item, bool isSuperAdmin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          // Thumbnail / Emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.hasImage
                  ? Image.asset(
                      item.resolvedImagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(item.iconEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                    )
                  : Center(
                      child: Text(item.iconEmoji, style: const TextStyle(fontSize: 22)),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // Name & Category
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
                    ),
                    if (item.isBestSeller) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HOT',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Current Price Display
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.priceFixed != null)
                  Text(
                    'Harga: Rp ${_formatNumber(item.priceFixed!)}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.caramel),
                  )
                else ...[
                  if (item.priceHot != null)
                    Text(
                      '🔥 Hot: Rp ${_formatNumber(item.priceHot!)}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.deepOrange),
                    ),
                  if (item.priceIce != null)
                    Text(
                      '❄️ Ice: Rp ${_formatNumber(item.priceIce!)}',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.blue.shade700),
                    ),
                ],
              ],
            ),
          ),

          // Status Switch (Tersedia / Habis)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.isAvailable ? 'Tersedia' : 'Habis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: item.isAvailable,
                activeThumbColor: Colors.green,
                onChanged: isSuperAdmin
                    ? (val) async {
                        final ok = await MenuManager.instance.toggleAvailability(id: item.id, isAvailable: val);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal mengubah status ketersediaan')),
                          );
                        }
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Edit Price Button (KHUSUS SUPER ADMIN)
          ElevatedButton.icon(
            onPressed: isSuperAdmin
                ? () => _showEditPriceDialog(context, item)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hanya Super Admin yang diizinkan mengubah harga menu.'),
                        backgroundColor: AppColors.espresso,
                      ),
                    );
                  },
            icon: Icon(Icons.edit_outlined, size: 13, color: isSuperAdmin ? Colors.white : Colors.black45),
            label: Text(
              'Ubah Harga',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: isSuperAdmin ? Colors.white : Colors.black45),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuperAdmin ? AppColors.caramel : Colors.grey.shade200,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, MenuItem item) {
    final hotController = TextEditingController(text: item.priceHot?.toString() ?? '');
    final iceController = TextEditingController(text: item.priceIce?.toString() ?? '');
    final fixedController = TextEditingController(text: item.priceFixed?.toString() ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.caramel.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.price_change_rounded, color: AppColors.caramel, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubah Harga: ${item.name}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.espresso),
                        ),
                        Text(
                          item.category,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Perubahan harga akan langsung tersinkronisasi secara realtime ke seluruh pengguna konsumen.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF795548), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (item.priceFixed != null || (item.priceHot == null && item.priceIce == null)) ...[
                        const Text('Harga Pas (Fixed Price)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: fixedController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            filled: true,
                            fillColor: const Color(0xFFFBF8F5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ] else ...[
                        if (item.tempOption != TempOption.iceOnly) ...[
                          const Text('Harga Panas (Hot)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: hotController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              filled: true,
                              fillColor: const Color(0xFFFBF8F5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (item.tempOption != TempOption.hotOnly) ...[
                          const Text('Harga Dingin (Ice)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: iceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              filled: true,
                              fillColor: const Color(0xFFFBF8F5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Batal', style: TextStyle(color: Colors.black54)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          final int? newFixed = int.tryParse(fixedController.text.trim());
                          final int? newHot = int.tryParse(hotController.text.trim());
                          final int? newIce = int.tryParse(iceController.text.trim());

                          final success = await MenuManager.instance.updateMenuItemPrice(
                            id: item.id,
                            priceFixed: newFixed,
                            priceHot: newHot,
                            priceIce: newIce,
                          );

                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? '✅ Harga "${item.name}" berhasil diperbarui & realtime tersinkron!'
                                      : '❌ Gagal memperbarui harga.',
                                ),
                                backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.espresso,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Harga', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
