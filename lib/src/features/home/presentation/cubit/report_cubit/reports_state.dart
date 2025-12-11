import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';

class ReportsState extends Equatable {
  final List<ActiveReportModel> activeReports;

  const ReportsState({this.activeReports = const <ActiveReportModel>[]});

  @override
  List<Object?> get props => [];
}
