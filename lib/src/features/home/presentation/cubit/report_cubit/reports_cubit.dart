import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(const ReportsState());

  void loadActiveReports() {
    // TODO: Replace with actual data from repository/service
    final activeReports = <ActiveReportModel>[
      ActiveReportModel(
        id: '001',
        adminRole: 'Admin',
        plateNumber: 'ABC123',
        reportedBy: 'John Doe',
        additionalNotes: 'Parked in no parking zone',
        attachedImage:
            'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(hours: 2)),
        carDetails: 'Red Toyota Camry',
      ),
      ActiveReportModel(
        id: '002',
        adminRole: 'Moderator',
        plateNumber: 'XYZ789',
        reportedBy: 'Jane Smith',
        additionalNotes: 'Expired parking permit',
        attachedImage:
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(hours: 5)),
        carDetails: 'Blue Honda Civic',
      ),
    ];

    emit(state.copyWith(activeReports: activeReports));
  }

  void loadHistoryReports() {
    // TODO: Replace with actual data from repository/service
    final historyReports = <HistoryReportModel>[
      HistoryReportModel(
        id: '101',
        adminRole: 'Admin',
        plateNumber: 'DEF456',
        reportedBy: 'Mike Johnson',
        expiredReason: 'Resolved',
        submitTime: DateTime.now().subtract(const Duration(days: 2)),
        carDetails: 'Black Ford Focus',
      ),
      HistoryReportModel(
        id: '102',
        adminRole: 'Moderator',
        plateNumber: 'GHI789',
        reportedBy: 'Sarah Williams',
        expiredReason: 'Cancelled',
        submitTime: DateTime.now().subtract(const Duration(days: 5)),
        carDetails: 'White Nissan Ultima',
      ),
    ];

    emit(state.copyWith(historyReports: historyReports));
  }
}
