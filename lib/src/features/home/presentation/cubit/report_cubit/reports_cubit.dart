import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_state.dart';
import 'package:park_my_whip/src/features/home/presentation/helpers/report_filter_helper.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(const ReportsState());

  /// Loads the Active tab with a short delay so the shimmer has time to play.
  Future<void> loadActiveReports() async {
    emit(state.copyWith(
      isLoadingActiveReports: true,
      activeReports: const <ActiveReportModel>[],
    ));

    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with API/service data once backend is connected.
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
      ActiveReportModel(
        id: 'REPORT-003-ULTRA-LONG-ID-STRING-FOR-TESTING-UI-OVERFLOW-AND-TEXT-WRAPPING-SCENARIOS',
        adminRole: 'Senior Parking Enforcement Administrator and Operations Manager',
        plateNumber: 'VERYLONGPLATE12345ABC',
        reportedBy: 'Christopher Alexander Montgomery III',
        additionalNotes:
            'This vehicle was found parked illegally in a clearly designated fire lane zone during peak hours, blocking emergency vehicle access. The driver was nowhere to be found despite multiple announcements over the public address system. The vehicle has been here for approximately 4 hours and 37 minutes according to our surveillance footage. Multiple warnings were issued but no response was received from the vehicle owner.',
        attachedImage:
            'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(minutes: 45)),
        carDetails:
            'Midnight Blue Metallic Mercedes-Benz S-Class AMG Performance Edition with Custom Chrome Wheels',
      ),
      ActiveReportModel(
        id: '004',
        adminRole: 'Supervisor',
        plateNumber: '1',
        reportedBy: 'M',
        additionalNotes: 'No permit visible on dashboard',
        attachedImage:
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(hours: 1)),
        carDetails: 'Car',
      ),
      ActiveReportModel(
        id: 'RPT-005',
        adminRole: 'Chief Parking Operations Director',
        plateNumber: 'ABC-DEF-GHI-123-456',
        reportedBy: 'Dr. Elizabeth Samantha Richardson-Wellington',
        additionalNotes:
            'Vehicle abandoned in premium reserved executive parking spot without proper authorization',
        attachedImage:
            'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(hours: 12)),
        carDetails: 'Pearl White Porsche Cayenne Turbo S E-Hybrid Coupe',
      ),
      ActiveReportModel(
        id: '006',
        adminRole: 'Security Lead',
        plateNumber: 'TEST123',
        reportedBy: 'Robert Martinez',
        additionalNotes: 'Blocking loading dock entrance',
        attachedImage:
            'https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(minutes: 30)),
        carDetails: 'Black Chevrolet Silverado 2500HD',
      ),
      ActiveReportModel(
        id: 'ACTIVE-REPORT-007',
        adminRole: 'Resident Manager',
        plateNumber: 'XYZ9876',
        reportedBy: 'Sarah Johnson',
        additionalNotes: 'Parked across two designated parking spaces',
        attachedImage:
            'https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(hours: 8)),
        carDetails: 'Yellow Ford Mustang GT Premium',
      ),
      ActiveReportModel(
        id: '008',
        adminRole: 'A',
        plateNumber: 'A1',
        reportedBy: 'J D',
        additionalNotes: 'N/A',
        attachedImage:
            'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1600&q=80',
        submitTime: DateTime.now().subtract(const Duration(days: 1)),
        carDetails: 'Vehicle',
      ),
    ];

    emit(state.copyWith(
      activeReports: activeReports,
      isLoadingActiveReports: false,
    ));
  }

  /// Loads the History tab with the same shimmer-friendly delay and data set.
  Future<void> loadHistoryReports() async {
    emit(state.copyWith(
      isLoadingHistoryReports: true,
      historyReports: const <HistoryReportModel>[],
      allHistoryReports: const <HistoryReportModel>[],
    ));

    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with API/service data once backend is connected.
    final historyReports = <HistoryReportModel>[
      HistoryReportModel(
        id: '101',
        adminRole: 'Resident Admin',
        plateNumber: 'DEF456',
        reportedBy: 'Mike Johnson',
        expiredReason: 'Expired Permit',
        submitTime: DateTime.now().subtract(const Duration(days: 2)),
        carDetails: 'Black Ford Focus',
      ),
      HistoryReportModel(
        id: '102',
        adminRole: 'Permit Control',
        plateNumber: 'GHI789',
        reportedBy: 'Sarah Williams',
        expiredReason: 'Unauthorized parking',
        submitTime: DateTime.now().subtract(const Duration(days: 5)),
        carDetails: 'White Nissan Ultima',
      ),
      HistoryReportModel(
        id: '103',
        adminRole: 'Super Admin',
        plateNumber: 'JKL012',
        reportedBy: 'Alex Brown',
        expiredReason: 'Parked in Fire Lane zone',
        submitTime: DateTime.now().subtract(const Duration(days: 10)),
        carDetails: 'Silver BMW X5',
      ),
      HistoryReportModel(
        id: '104',
        adminRole: 'Resident Admin',
        plateNumber: 'MNO345',
        reportedBy: 'Emily Davis',
        expiredReason: 'Expired Permit',
        submitTime: DateTime.now().subtract(const Duration(days: 400)),
        carDetails: 'Green Tesla Model 3',
      ),
      HistoryReportModel(
        id: 'HISTORY-REPORT-105-EXTREMELY-LONG-IDENTIFIER-FOR-COMPREHENSIVE-UI-TESTING-AND-OVERFLOW-SCENARIOS',
        adminRole: 'Executive Director of Parking Management and Enforcement Operations',
        plateNumber: 'SUPERLONGPLATENUMBER999',
        reportedBy: 'Dr. Benjamin Alexander Christopher Montgomery-Richardson III Esq.',
        expiredReason:
            'Unauthorized parking in clearly designated visitor-only parking area during restricted hours without proper authorization documentation or valid temporary permit displayed on vehicle dashboard',
        submitTime: DateTime.now().subtract(const Duration(days: 15)),
        carDetails:
            'Sapphire Blue Metallic BMW M8 Competition Gran Coupe with Premium Executive Package',
      ),
      HistoryReportModel(
        id: 'H-106',
        adminRole: 'Admin',
        plateNumber: 'XYZ123ABC',
        reportedBy: 'Jennifer Thompson',
        expiredReason: 'No permit displayed',
        submitTime: DateTime.now().subtract(const Duration(days: 7)),
        carDetails: 'Red Audi A4 Quattro',
      ),
      HistoryReportModel(
        id: '107',
        adminRole: 'A',
        plateNumber: '1',
        reportedBy: 'J',
        expiredReason: 'Expired',
        submitTime: DateTime.now().subtract(const Duration(days: 30)),
        carDetails: 'Car',
      ),
      HistoryReportModel(
        id: 'HIST-108',
        adminRole: 'Senior Compliance Officer',
        plateNumber: 'ABC-123-XYZ-789',
        reportedBy: 'Michael Stephen Rodriguez',
        expiredReason: 'Parking in handicap accessible space without proper authorization',
        submitTime: DateTime.now().subtract(const Duration(days: 45)),
        carDetails: 'Graphite Grey Lexus RX 450h Luxury Premium',
      ),
      HistoryReportModel(
        id: '109',
        adminRole: 'Security',
        plateNumber: 'TEST999',
        reportedBy: 'David Kim',
        expiredReason: 'Double parking violation',
        submitTime: DateTime.now().subtract(const Duration(days: 60)),
        carDetails: 'White Toyota RAV4',
      ),
      HistoryReportModel(
        id: '110',
        adminRole: 'Parking Supervisor',
        plateNumber: 'ABCD1234',
        reportedBy: 'Amanda Chen',
        expiredReason: 'Blocking fire hydrant',
        submitTime: DateTime.now().subtract(const Duration(days: 90)),
        carDetails: 'Silver Nissan Altima',
      ),
      HistoryReportModel(
        id: 'REPORT-111',
        adminRole: 'Chief Security Administrator and Safety Coordinator',
        plateNumber: 'ULTRALONG-PLATE-12345',
        reportedBy: 'Professor Elizabeth Marie Anderson-Wellington PhD',
        expiredReason:
            'Long-term unauthorized parking in executive reserved section without valid credentials',
        submitTime: DateTime.now().subtract(const Duration(days: 120)),
        carDetails: 'Jet Black Mercedes-Benz GLE 63 S AMG Coupe with Performance Exhaust',
      ),
      HistoryReportModel(
        id: '112',
        adminRole: 'Staff',
        plateNumber: 'MIN1',
        reportedBy: 'L W',
        expiredReason: 'No permit',
        submitTime: DateTime.now().subtract(const Duration(days: 150)),
        carDetails: 'Vehicle',
      ),
    ];

    emit(state.copyWith(
      historyReports: historyReports,
      allHistoryReports: historyReports,
      isLoadingHistoryReports: false,
    ));
  }

  void applyFilter(ReportFilterCriteria criteria) {
    final filteredReports = ReportFilterHelper.applyFilters(
      state.allHistoryReports,
      criteria,
    );

    emit(state.copyWith(
      historyReports: filteredReports,
      filterCriteria: criteria,
    ));
  }

  void resetFilter() {
    emit(state.copyWith(
      historyReports: state.allHistoryReports,
      filterCriteria: const ReportFilterCriteria(),
    ));
  }

  void removeFilter(String filterType) {
    ReportFilterCriteria newCriteria = state.filterCriteria;

    if (filterType == 'timeRange') {
      newCriteria = newCriteria.copyWith(timeRange: TimeRangeFilter.all);
    } else if (filterType == 'violationType') {
      newCriteria = newCriteria.copyWith(violationType: ViolationTypeFilter.all);
    } else if (filterType == 'reportedBy') {
      newCriteria = newCriteria.copyWith(reportedBy: ReportedByFilter.all);
    }

    applyFilter(newCriteria);
  }

  /// Returns active filter labels for history tab filter section
  List<FilterChipData> getActiveFilterLabels() {
    return ReportFilterHelper.getActiveFilters(state.filterCriteria);
  }

  /// Handles back button press and navigation logic
  void handleBackPress(int currentTabIndex, Function(int) animateToTab) {
    if (currentTabIndex == 1) {
      // On history tab, go back to active tab
      animateToTab(0);
    } else {
      // On active tab, go to patrol
      getIt<DashboardCubit>().changePage(0);
    }
  }

  /// Handles tab changes and loads appropriate data
  void onTabChanged(int tabIndex) {
    if (tabIndex == 0) {
      loadActiveReports();
    } else if (tabIndex == 1) {
      resetFilter();
      loadHistoryReports();
    }
  }
}
