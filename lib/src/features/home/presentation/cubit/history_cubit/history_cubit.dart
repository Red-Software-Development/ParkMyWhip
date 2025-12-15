import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/history_cubit/history_state.dart';
import 'package:park_my_whip/src/features/home/presentation/helpers/towing_filter_helper.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState());

  /// Loads towing history with a short delay so the shimmer animation can play.
  Future<void> loadTowingHistory() async {
    emit(state.copyWith(
      isLoadingHistory: true,
      towingHistory: const <TowingEntryModel>[],
      allTowingHistory: const <TowingEntryModel>[],
      selectedEntry: null,
      showDetail: false,
    ));

    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with actual data from repository/service
    final towingHistory = <TowingEntryModel>[
      TowingEntryModel(
        plateNumber: 'ULTRA-LONG-PLATE-ALPHA-9999999',
        location: 'North Ridge Residences • Tower 7 • Level 12 • Premium Electric Vehicle Charging Gallery • Bay A23 directly beside the panoramic glass atrium',
        towCompany: 'Metropolitan Precision Recovery and Rapid Response Towing Cooperative',
        reason: 'Extended overnight parking in a space reserved for emergency response teams during quarterly fire-safety simulation drills',
        notes: 'Vehicle remained connected to the charging pedestal for 18 consecutive hours despite three digital notifications, a windshield advisory, and a concierge phone call. The cable also obstructed a secondary charger used by maintenance vans.',
        towDate: DateTime.now().subtract(const Duration(hours: 5)),
        attachedImage: 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Christopher Alexander Montgomery III — Senior Compliance Strategist',
      ),
      TowingEntryModel(
        plateNumber: 'Q',
        location: 'B-1',
        towCompany: 'Quick Tow Inc',
        reason: 'Z',
        notes: 'Minimal test entry to validate compact layouts and chips.',
        towDate: DateTime.now().subtract(const Duration(days: 1)),
        attachedImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'A',
      ),
      TowingEntryModel(
        plateNumber: 'PERMIT-VOID-77777-LATE-WINTER-AUDIT-ENTRY',
        location: 'Skyline Mixed-Use Campus — Loading Promenade that wraps behind the culinary pavilion near the mirrored water feature',
        towCompany: 'City Tow Service',
        reason: 'Expired seasonal vendor access tag detected during RFID scan',
        notes: 'Vendor kiosk left a refrigerated van plugged into a standard outlet for 36 hours. Condensation pooled, freezing the adjacent handicap ramp overnight.',
        towDate: DateTime.now().subtract(const Duration(days: 8)),
        attachedImage: 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Permit Control Officer — West District',
      ),
      TowingEntryModel(
        plateNumber: 'STACKED-TRAILER-CHAIN-OF-THREE-INSPECTION',
        location: 'Harborfront Logistics Annex, Docking Lane 42 (length-restricted corridor)',
        towCompany: 'Harbor & Rail Integrated Recovery Group',
        reason: 'Triple-stacked trailer chain exceeded posted clearance and blocked automated gate sensors',
        notes: 'Tow required synchronized removal plan. Document verifies UI can show multi-sentence narratives with hyphenated phrasing and parenthetical clarifiers.',
        towDate: DateTime.now().subtract(const Duration(days: 30)),
        attachedImage: 'https://images.unsplash.com/photo-1486496146582-9ffcd0b2b2b7?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Operations Command — Logistics Patrol',
      ),
      TowingEntryModel(
        plateNumber: 'VERYLONGPLATE1234567890WITHSUFFIX',
        location: 'Innovation District — Autonomous Delivery Zone directly in front of the glass footbridge between Labs 3 and 4',
        towCompany: 'Metro Towing',
        reason: 'Manual vehicle parked inside autonomous-only corridor',
        notes: 'Navigation cones were relocated by the driver, forcing delivery bots to reroute twice and triggering a site-wide safety pause.',
        towDate: DateTime.now().subtract(const Duration(days: 65)),
        attachedImage: 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Autonomy Safety Desk',
      ),
      TowingEntryModel(
        plateNumber: 'SNOW-STORM-ARCHIVE-CASE-0001',
        location: 'Summit Ridge Chalet Overflow Lot — Row 18 spot 4',
        towCompany: 'Alpine Lift & Tow',
        reason: 'Snow emergency protocol — lot needed for plow staging',
        notes: 'Car buried overnight; license plate partially obstructed, requiring manual VIN verification. Entry stress-tests date formatting >1 year old.',
        towDate: DateTime.now().subtract(const Duration(days: 410)),
        attachedImage: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Mountain Patrol Supervisor',
      ),
      TowingEntryModel(
        plateNumber: 'LEVEL-7-FLOODGATE-INCIDENT',
        location: 'Underground Reservoir Access Tunnel with echo-prone walls requiring ellipsis coverage...',
        towCompany: 'Emergency Response Fleet',
        reason: 'Vehicle stopped on hydraulic floodgate hinges during maintenance window',
        notes: 'Comprehensive narrative describing how sensors kept reopening once the sedan rolled back 4cm each time an alert sounded, forcing manual overrides and multiple QA screenshots.',
        towDate: DateTime.now().subtract(const Duration(hours: 300)),
        attachedImage: 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Infrastructure Reliability Lead',
      ),
      TowingEntryModel(
        plateNumber: 'HERITAGE-PARADE-CLOSURE-CASE',
        location: 'Old Town Heritage Square — Parade route barrier lane',
        towCompany: 'City Tow Service',
        reason: 'Vehicle ignored rolling roadblock instructions',
        notes: 'Short description to ensure UI gracefully handles mid-length entries without wrapping issues.',
        towDate: DateTime.now().subtract(const Duration(days: 120)),
        attachedImage: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1600&q=80',
        reportedBy: 'Event Command Center',
      ),
    ];

    final filteredHistory = TowingFilterHelper.applyFilters(
      towingHistory,
      state.filterCriteria,
    );

    emit(state.copyWith(
      towingHistory: filteredHistory,
      allTowingHistory: towingHistory,
      isLoadingHistory: false,
    ));
  }

  void applyFilter(ReportFilterCriteria criteria) {
    final filteredHistory = TowingFilterHelper.applyFilters(
      state.allTowingHistory,
      criteria,
    );
    
    emit(state.copyWith(
      towingHistory: filteredHistory,
      filterCriteria: criteria,
    ));
  }

  void resetFilter() {
    emit(state.copyWith(
      towingHistory: state.allTowingHistory,
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

  void selectEntry(TowingEntryModel entry) {
    emit(state.copyWith(selectedEntry: entry, showDetail: true));
  }

  void backToList() {
    emit(state.copyWith(selectedEntry: null, showDetail: false));
  }

  /// Handles back button press - navigates to patrol if needed
  void handleBackPress() {
    if (state.showDetail) {
      backToList();
    } else {
      resetFilter();
      getIt<DashboardCubit>().changePage(0);
    }
  }

  /// Returns active filter labels for display
  List<FilterChipData> getActiveFilterLabels() {
    return TowingFilterHelper.getActiveFilters(state.filterCriteria);
  }
}
