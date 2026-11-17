// lib/models/shift_schedule_model.dart

class ShiftScheduleModel {
  final String id;
  final String userId;
  final String userName;
  final String? userEmail;
  final String shiftName; // Shift Pagi (08:00 - 16:00), Shift Malam (16:00 - 23:00)
  final String branchName;
  final DateTime shiftDate;
  final String startTime;
  final String endTime;
  final String status; // scheduled, on_duty, completed, absent
  final String? notes;

  const ShiftScheduleModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.shiftName,
    this.branchName = 'Outlet Seuma Pusat - Lhokseumawe',
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    this.status = 'scheduled',
    this.notes,
  });

  bool get isOnDuty => status == 'on_duty';

  String get statusBadge {
    switch (status) {
      case 'on_duty':
        return '🟢 Sedang Bertugas (On Duty)';
      case 'completed':
        return '⚪ Selesai Shift';
      case 'absent':
        return '🔴 Berhalangan / Izin';
      case 'scheduled':
      default:
        return '🟡 Terjadwal';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'shift_name': shiftName,
    'branch_name': branchName,
    'shift_date': shiftDate.toIso8601String().split('T').first,
    'start_time': startTime,
    'end_time': endTime,
    'status': status,
    'notes': notes,
  };

  factory ShiftScheduleModel.fromJson(Map<String, dynamic> json, {String? defaultUserName}) {
    return ShiftScheduleModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['profiles']?['name']?.toString() ?? defaultUserName ?? 'Barista Seuma',
      userEmail: json['profiles']?['email']?.toString(),
      shiftName: json['shift_name']?.toString() ?? 'Shift Reguler',
      branchName: json['branch_name']?.toString() ?? 'Outlet Seuma Pusat - Lhokseumawe',
      shiftDate: json['shift_date'] != null
          ? DateTime.tryParse(json['shift_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['start_time']?.toString() ?? '08:00',
      endTime: json['end_time']?.toString() ?? '16:00',
      status: json['status']?.toString() ?? 'scheduled',
      notes: json['notes']?.toString(),
    );
  }
}
