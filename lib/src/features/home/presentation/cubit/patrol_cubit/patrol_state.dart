import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/location_model.dart';
import 'package:park_my_whip/src/features/home/data/models/permit_data_model.dart';

class PatrolState extends Equatable {
  final List<PermitModel> permits;
  final bool isPermitSearchActive;
  final List<LocationModel> locations;
  final bool showPermit;
  final String selectedLocation;
  final bool isLoadingLocations;
  final bool isLoadingPermits;
  final String username;
  const PatrolState({
    this.permits = const [],
    this.isPermitSearchActive = false,
    this.locations = const [],
    this.showPermit = false,
    this.selectedLocation = '',
    this.isLoadingLocations = false,
    this.isLoadingPermits = false,
    this.username = 'Mohammed',
  });

  PatrolState copyWith({
    List<PermitModel>? permits,
    bool? isPermitSearchActive,
    List<LocationModel>? locations,
    bool? showPermit,
    String? selectedLocation,
    bool? isLoadingLocations,
    bool? isLoadingPermits,
    String? username,
  }) {
    return PatrolState(
      permits: permits ?? this.permits,
      isPermitSearchActive: isPermitSearchActive ?? this.isPermitSearchActive,
      locations: locations ?? this.locations,
      showPermit: showPermit ?? this.showPermit,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingPermits: isLoadingPermits ?? this.isLoadingPermits,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [
    permits,
    isPermitSearchActive,
    locations,
    showPermit,
    selectedLocation,
    isLoadingLocations,
    isLoadingPermits,
    username,
  ];
}
