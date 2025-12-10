import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/data/models/location_model.dart';
import 'package:park_my_whip/src/features/home/data/models/permit_data_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_state.dart';

class PatrolCubit extends Cubit<PatrolState> {
  PatrolCubit() : super(const PatrolState());

  final TextEditingController searchPatrolController = TextEditingController();

  final TextEditingController searchPermitController = TextEditingController();

  final List<PermitModel> dummyPermits = [
    PermitModel(
      id: 'PERMIT-001',
      permitType: 'Monthly',
      expiryDate: DateTime.parse('2025-01-31'),
      vehicleInfo: VehicleInfo(
        model: 'Chevrolet Silvered',
        year: '2024',
        color: 'Black',
      ),
      plateSpotInfo: PlateSpotInfo(plateNumber: 'ABC 123', spotNumber: '3A'),
    ),

    PermitModel(
      id: 'PERMIT-002',
      permitType: 'Yearly',
      expiryDate: DateTime.parse('2025-12-31'),
      vehicleInfo: VehicleInfo(
        model: 'Toyota Corolla',
        year: '2020',
        color: 'White',
      ),
      plateSpotInfo: PlateSpotInfo(plateNumber: 'XYZ 987', spotNumber: '12B'),
    ),

    PermitModel(
      id: 'PERMIT-003',
      permitType: 'Weekly',
      expiryDate: DateTime.parse('2025-02-07'),
      vehicleInfo: VehicleInfo(
        model: 'Honda Civic',
        year: '2021',
        color: 'Blue',
      ),
      plateSpotInfo: PlateSpotInfo(plateNumber: 'JHD 552', spotNumber: '7C'),
    ),

    PermitModel(
      id: 'PERMIT-004',
      permitType: 'Daily',
      expiryDate: DateTime.parse('2025-01-12'),
      vehicleInfo: VehicleInfo(model: 'Ford F-150', year: '2022', color: 'Red'),
      plateSpotInfo: PlateSpotInfo(plateNumber: 'FTR 221', spotNumber: '19D'),
    ),

    PermitModel(
      id: 'PERMIT-005',
      permitType: 'Monthly',
      expiryDate: DateTime.parse('2025-03-01'),
      vehicleInfo: VehicleInfo(model: 'BMW X5', year: '2023', color: 'Grey'),
      plateSpotInfo: PlateSpotInfo(plateNumber: 'BMV 005', spotNumber: '22E'),
    ),
  ];

  final List<LocationModel> dummyLocations = [
    LocationModel(
      id: 'LOC-001',
      title: 'Yugo University Club',
      description:
          'Student housing and community space near the University of Maryland.',
    ),
    LocationModel(
      id: 'LOC-002',
      title: 'Downtown Parking Garage',
      description: 'Secure 24/7 public parking garage with 300+ spaces.',
    ),
    LocationModel(
      id: 'LOC-003',
      title: 'College Park Metro Station',
      description:
          'Major metro stop with daily commuters and Park & Ride availability.',
    ),
    LocationModel(
      id: 'LOC-004',
      title: 'Campus View Residences',
      description: 'Residential apartments located near the UMD campus.',
    ),
    LocationModel(
      id: 'LOC-005',
      title: 'Baltimore Ave Food Court',
      description:
          'Popular dining area with fast food, cafés, and parking spots.',
    ),
  ];

  //***************************************Location ********************************* */
  void loadLocationData() {
    emit(state.copyWith(locations: dummyLocations));
  }

  void searchLocations(String query) {
    // if search empty → return full list
    if (query.isEmpty) {
      emit(state.copyWith(locations: dummyLocations));
      return;
    }

    final filtered = dummyLocations.where((location) {
      final title = location.title.toLowerCase();
      final description = location.description.toLowerCase();
      return title.contains(query.toLowerCase()) ||
          description.contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(locations: filtered));
  }

  void selectLocation({
    required String locationId,
    required String locationTitle,
  }) {
    emit(state.copyWith(selectedLocation: locationTitle, showPermit: true));
    loadPermitData(locationId: locationId);
  }

  //***************************************Permit ********************************* */

  void loadPermitData({required String locationId}) {
    emit(state.copyWith(permits: dummyPermits));
  }

  void searchPermits(String query) {
    // if search empty → return full list
    if (query.isEmpty) {
      emit(state.copyWith(isPermitSearchActive: false));
      emit(state.copyWith(permits: dummyPermits));
      return;
    }

    final filtered = dummyPermits.where((permit) {
      final plate = permit.plateSpotInfo.plateNumber.toLowerCase();
      return plate.contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(isPermitSearchActive: true, permits: filtered));
  }

  void closePermit() {
    emit(
      state.copyWith(showPermit: false, selectedLocation: null, permits: []),
    );
  }

  void clearPermitSearch() {
    searchPermitController.clear();
    emit(state.copyWith(isPermitSearchActive: false, permits: dummyPermits));
  }

  void navigateToTowCar() {
    clearPermitSearch();
    closePermit();
    getIt<DashboardCubit>().changePage(2);
  }
}
