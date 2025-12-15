import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/data/models/location_model.dart';
import 'package:park_my_whip/src/features/home/data/models/permit_data_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_state.dart';

class PatrolCubit extends Cubit<PatrolState> {
  PatrolCubit() : super(const PatrolState()) {
    loadLocationData();
  }

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
    PermitModel(
      id: 'PERMIT-006-VERY-LONG-ID-STRING-TESTING-OVERFLOW-HANDLING-IN-UI-COMPONENTS',
      permitType: 'Half Yearly',
      expiryDate: DateTime.parse('2025-06-15'),
      vehicleInfo: VehicleInfo(
        model: 'Mercedes-Benz G-Class AMG G63 Performance Edition Ultra Luxury',
        year: '2024',
        color: 'Obsidian Black Metallic with Chrome Accents',
      ),
      plateSpotInfo: PlateSpotInfo(
        plateNumber: 'VERYLONGPLATE12345',
        spotNumber: 'SECTION-A-LEVEL-3-SPOT-999',
      ),
    ),
    PermitModel(
      id: 'P-007',
      permitType: 'Daily',
      expiryDate: DateTime.parse('2025-01-15'),
      vehicleInfo: VehicleInfo(
        model: 'Tesla Model S Plaid Long Range All-Wheel Drive Performance Package',
        year: '2025',
        color: 'Pearl White Multi-Coat',
      ),
      plateSpotInfo: PlateSpotInfo(plateNumber: 'ABC123DEF456GHI789', spotNumber: '1'),
    ),
    PermitModel(
      id: 'PERMIT-008',
      permitType: 'Quarterly',
      expiryDate: DateTime.parse('2025-02-28'),
      vehicleInfo: VehicleInfo(
        model: 'Porsche Taycan Turbo S Cross Turismo Executive',
        year: '2024',
        color: 'Frozen Berry Metallic Special Edition',
      ),
      plateSpotInfo: PlateSpotInfo(
        plateNumber: '1',
        spotNumber: 'UNDERGROUND-PARKING-LEVEL-B5-RESERVED-VIP-SECTION',
      ),
    ),
    PermitModel(
      id: 'P-MIN',
      permitType: 'Daily',
      expiryDate: DateTime.parse('2025-01-20'),
      vehicleInfo: VehicleInfo(model: 'X', year: '99', color: 'R'),
      plateSpotInfo: PlateSpotInfo(plateNumber: '1', spotNumber: 'A'),
    ),
    PermitModel(
      id: 'PERMIT-010',
      permitType: 'Monthly',
      expiryDate: DateTime.parse('2025-05-30'),
      vehicleInfo: VehicleInfo(
        model: 'Lamborghini Aventador SVJ Roadster Special Edition',
        year: '2023',
        color: 'Arancio Argos Orange Pearl',
      ),
      plateSpotInfo: PlateSpotInfo(
        plateNumber: 'LAMBORGHINI-SVJ-2023-SPECIAL',
        spotNumber: 'PREMIUM-SPOT-EXECUTIVE-LEVEL-ROOFTOP-A1',
      ),
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
    LocationModel(
      id: 'LOC-006-VERY-LONG-LOCATION-ID-FOR-TESTING-OVERFLOW-AND-UI-BREAKING-SCENARIOS',
      title: 'The Grand Imperial International Business Center and Corporate Executive Headquarters Complex',
      description:
          'This is an extremely long description designed to test text wrapping, overflow handling, and UI responsiveness across different screen sizes. The facility features state-of-the-art amenities, cutting-edge technology infrastructure, premium parking spaces with electric vehicle charging stations, 24/7 security surveillance systems, biometric access control, climate-controlled environments, and comprehensive visitor management protocols.',
    ),
    LocationModel(
      id: 'LOC-007',
      title: 'X',
      description: 'A',
    ),
    LocationModel(
      id: 'LOC-008',
      title: 'Shopping Mall Complex with Multiple Retail Outlets and Entertainment Facilities',
      description: 'Large commercial center.',
    ),
    LocationModel(
      id: 'LOC-009',
      title: 'Airport Terminal',
      description:
          'International airport terminal with short-term and long-term parking options, shuttle services, car rental facilities, electric vehicle charging infrastructure, accessible parking spaces, covered parking areas, outdoor lots, premium valet services, and real-time parking availability monitoring systems integrated with mobile applications for seamless customer experience.',
    ),
    LocationModel(
      id: 'LOC-010',
      title: 'Hospital Emergency Medical Center',
      description: 'Emergency parking for medical facility visitors.',
    ),
    LocationModel(
      id: 'L-11',
      title: 'Stadium',
      description: 'Sports venue parking.',
    ),
    LocationModel(
      id: 'LOC-012',
      title: 'Beach Resort & Recreational Waterfront Area',
      description:
          'Coastal parking facility with beach access, restroom facilities, picnic areas, and seasonal passes available.',
    ),
    LocationModel(
      id: 'LOC-013-TEST-SPECIAL-CHARS-!@#\$%^&*()_+-=[]{}|;:",.<>?/',
      title: 'Test Location with Special Characters: !@#\$%^&*()',
      description:
          'Testing special character handling in UI: <>?:"{}|_+-=[]\\;/.,~`',
    ),
    LocationModel(
      id: 'LOC-014',
      title: 'University Research Laboratory and Advanced Technology Innovation Hub',
      description: 'Research facility with restricted access parking zones.',
    ),
    LocationModel(
      id: 'LOC-015',
      title: 'Convention Center',
      description: 'Event venue with massive parking capacity for conferences, exhibitions, trade shows, and large-scale public events.',
    ),
  ];

  //***************************************Location ********************************* */
  void loadLocationData() async {
    emit(state.copyWith(isLoadingLocations: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isLoadingLocations: false, locations: dummyLocations));
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

  void loadPermitData({required String locationId}) async {
    emit(state.copyWith(isLoadingPermits: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isLoadingPermits: false, permits: dummyPermits));
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
