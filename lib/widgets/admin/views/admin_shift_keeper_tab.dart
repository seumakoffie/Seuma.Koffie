// lib/widgets/admin/views/admin_shift_keeper_tab.dart
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/shift_schedule_model.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';

class AdminShiftKeeperTab extends StatefulWidget {
  const AdminShiftKeeperTab({super.key});

  @override
  State<AdminShiftKeeperTab> createState() => _AdminShiftKeeperTabState();
}

class _AdminShiftKeeperTabState extends State<AdminShiftKeeperTab> {
  void _openAddShiftDialog() {
    final admin = AdminManager.instance;
    final keepers = admin.shiftKeepers;
    if (keepers.isEmpty) return;

    UserModel selectedKeeper = keepers.first;
    String shiftName = 'Shift Pagi (08:00 - 16:00)';
    String startTime = '08:00';
    String endTime = '16:00';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.espresso),
                  SizedBox(width: 8),
                  Text('Jadwal Shift Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Pilih Barista / Staf Shift:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<UserModel>(
                      initialValue: selectedKeeper,
                      items: keepers.map((k) {
                        return DropdownMenuItem(
                          value: k,
                          child: Text('${k.name} (${k.role.displayName})', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedKeeper = val);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Jenis Shift:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: shiftName,
                      items: const [
                        DropdownMenuItem(value: 'Shift Pagi (08:00 - 16:00)', child: Text('Shift Pagi (08:00 - 16:00)')),
                        DropdownMenuItem(value: 'Shift Malam (16:00 - 23:00)', child: Text('Shift Malam (16:00 - 23:00)')),
                        DropdownMenuItem(value: 'Shift Full-Day Event', child: Text('Shift Full-Day Event')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            shiftName = val;
                            if (val.contains('Pagi')) {
                              startTime = '08:00';
                              endTime = '16:00';
                            } else if (val.contains('Malam')) {
                              startTime = '16:00';
                              endTime = '23:00';
                            }
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Catatan Penugasan / Posisi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Kalibrasi Sanger & standby kasir.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.espresso,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final newSchedule = ShiftScheduleModel(
                      id: 'shift-${DateTime.now().millisecondsSinceEpoch}',
                      userId: selectedKeeper.id,
                      userName: selectedKeeper.name,
                      userEmail: selectedKeeper.email,
                      shiftName: shiftName,
                      branchName: 'Outlet Seuma Pusat - Lhokseumawe',
                      shiftDate: DateTime.now(),
                      startTime: startTime,
                      endTime: endTime,
                      status: 'on_duty',
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );
                    final messenger = ScaffoldMessenger.of(context);
                    await admin.addShiftSchedule(newSchedule);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Jadwal shift berhasil ditambahkan ke database Supabase!'),
                        backgroundColor: AppColors.espresso,
                      ),
                    );
                  },
                  child: const Text('Simpan Jadwal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminManager.instance,
      builder: (context, _) {
        final admin = AdminManager.instance;
        final keepers = admin.shiftKeepers;
        final schedules = admin.shiftSchedules;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Bar & Overview
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Penjaga Shift & Barista Outlet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.espresso),
                ),
                Text(
                  'Outlet Seuma Pusat - Lhokseumawe & Sekitarnya',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _openAddShiftDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Atur Jadwal Shift', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Split View: Staf Aktif vs Jadwal Hari Ini
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom 1: Daftar Staf Shift (40%)
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 18, color: AppColors.espresso),
                          const SizedBox(width: 8),
                          Text(
                            'Staf Terdaftar (${keepers.length})',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: keepers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final k = keepers[index];
                            final isLead = k.role == UserRole.admin;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isLead ? AppColors.creamLight : const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isLead ? AppColors.caramel.withValues(alpha: 0.3) : Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isLead ? AppColors.caramel : const Color(0xFF607D8B),
                                    child: Text(
                                      isLead ? '👑' : '☕',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          k.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.espresso),
                                        ),
                                        Text(
                                          k.email,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isLead ? Colors.amber.shade100 : Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      k.role.displayName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isLead ? Colors.amber.shade900 : Colors.teal.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Kolom 2: Jadwal Shift Outlet Hari Ini (60%)
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.espresso),
                              SizedBox(width: 8),
                              Text(
                                'Jadwal Operasional Hari Ini',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('🟢 Outlet Open (08:00 - 23:00)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: schedules.isEmpty
                            ? const Center(child: Text('Belum ada jadwal shift untuk hari ini.'))
                            : ListView.separated(
                                itemCount: schedules.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final s = schedules[index];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: s.isOnDuty ? const Color(0xFFF1F8E9) : const Color(0xFFFAFAFA),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: s.isOnDuty ? const Color(0xFFAED581) : Colors.grey.shade200,
                                        width: s.isOnDuty ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: s.isOnDuty ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.access_time_filled,
                                            color: s.isOnDuty ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    s.shiftName,
                                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    s.statusBadge,
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                'Penjaga: ${s.userName} • Jam: ${s.startTime} - ${s.endTime} WIB',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                              ),
                                              if (s.notes != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Tugas: ${s.notes}',
                                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                                                ),
                                              ],
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  },
);
  }
}
