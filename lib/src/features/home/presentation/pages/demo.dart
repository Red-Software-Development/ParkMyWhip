// import 'package:flutter/material.dart';

// class Demo extends StatelessWidget {
//   const Demo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Flexible(
//   child: Column(
//     children: [
//       Align(
//         alignment: Alignment(0.0, 0),
//         child: TabBar(
//           labelColor: FlutterFlowTheme.of(context).primaryText,
//           unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
//           labelStyle: FlutterFlowTheme.of(context).bodySmall.override(
//                 font: GoogleFonts.inter(
//                   fontWeight: FontWeight.w600,
//                   fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
//                 ),
//                 fontSize: MediaQuery.sizeOf(context).width * 0.035,
//                 letterSpacing: 0.0,
//                 fontWeight: FontWeight.w600,
//                 fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
//               ),
//           unselectedLabelStyle: FlutterFlowTheme.of(context)
//               .titleSmall
//               .override(
//                 font: GoogleFonts.inter(
//                   fontWeight:
//                       FlutterFlowTheme.of(context).titleSmall.fontWeight,
//                   fontStyle:
//                       FlutterFlowTheme.of(context).titleSmall.fontStyle,
//                 ),
//                 fontSize: MediaQuery.sizeOf(context).width * 0.034,
//                 letterSpacing: 0.0,
//                 fontWeight:
//                     FlutterFlowTheme.of(context).titleSmall.fontWeight,
//                 fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
//               ),
//           indicatorColor: FlutterFlowTheme.of(context).primary,
//           indicatorWeight: 2.0,
//           tabs: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 2.0, 0.0),
//                   child: Icon(
//                     FFIcons.kframe2147225713,
//                     size: MediaQuery.sizeOf(context).width * 0.05,
//                   ),
//                 ),
//                 Tab(
//                   text: 'History   ',
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 2.0, 0.0),
//                   child: Icon(
//                     FFIcons.kframe2147225714,
//                     size: MediaQuery.sizeOf(context).width * 0.05,
//                   ),
//                 ),
//                 Tab(
//                   text: 'Upcoming',
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 2.0, 0.0),
//                   child: Icon(
//                     FFIcons.kframe2147225715,
//                     size: MediaQuery.sizeOf(context).width * 0.05,
//                   ),
//                 ),
//                 Tab(
//                   text: 'Uncovered',
//                 ),
//               ],
//             ),
//           ],
//           controller: _model.tabBarController,
//           onTap: (i) async {
//             [
//               () async {
//                 FFAppState().showIncompleatAlert = true;
//                 safeSetState(() {});
//               },
//               () async {
//                 FFAppState().showIncompleatAlert = true;
//                 safeSetState(() {});
//               },
//               () async {}
//             ][i]();
//           },
//         ),
//       ),
//       Expanded(
//         child: TabBarView(
//           controller: _model.tabBarController,
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding:
//                       EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         InkWell(
//                           splashColor: Colors.transparent,
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () async {
//                             _model.selectedHistoryFilter =
//                                 VisitFilter.yesterday;
//                             safeSetState(() {});
//                             FFAppState().showIncompleatAlert = true;
//                             safeSetState(() {});
//                           },
//                           child: wrapWithModel(
//                             model: _model.dateFilterModel1,
//                             updateCallback: () => safeSetState(() {}),
//                             child: DateFilterWidget(
//                               index: 0,
//                               selectedIndex: _model.selectedHistoryFilter ==
//                                       VisitFilter.yesterday
//                                   ? 0
//                                   : -1,
//                               filterText: 'Yesterday',
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           splashColor: Colors.transparent,
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () async {
//                             _model.selectedHistoryFilter =
//                                 VisitFilter.last7Days;
//                             safeSetState(() {});
//                             FFAppState().showIncompleatAlert = true;
//                             safeSetState(() {});
//                           },
//                           child: wrapWithModel(
//                             model: _model.dateFilterModel2,
//                             updateCallback: () => safeSetState(() {}),
//                             child: DateFilterWidget(
//                               index: 1,
//                               selectedIndex: _model.selectedHistoryFilter ==
//                                       VisitFilter.last7Days
//                                   ? 1
//                                   : -1,
//                               filterText: 'Last 7 days',
//                             ),
//                           ),
//                         ),
//                       ].divide(SizedBox(width: 8.0)),
//                     ),
//                   ),
//                 ),
//                 Flexible(
//                   child: Container(
//                     width: double.infinity,
//                     child: custom_widgets.PowerSyncQurey(
//                       width: double.infinity,
//                       sql:
//                           'SELECT \n  visits.*, \n    clients.keysafe_code, \n  clients.address, \n  clients.gps_longitude, \nclients.nfc_id, \n  clients.gps_latitude, \n  clients.name AS client_name \nFROM visits \nLEFT JOIN clients ON visits.client_id = clients.id \nWHERE visits.primary_carer_id = :id OR visits.secondary_carer_id = :id2  \n  ORDER BY scheduled_end_time DESC;',
//                       parameters: <String, dynamic>{
//                         'id': currentUserUid,
//                         'id2': currentUserUid,
//                       },
//                       enableDebugLogs: false,
//                       refreshTrigger: FFAppState().refreshVisits,
//                       backButtonPress: () async {},
//                       child: (List<dynamic> data) =>
//                           VisitsListWithIncompleteAlertWidget(
//                         visitsData:
//                             functions.convertJsonToVisitsRow(data.toList()),
//                         incompleateVistsIds: functions.getIncompleateVists(
//                             functions
//                                 .convertJsonToVisitsRow(data.toList())
//                                 .toList(),
//                             currentUserUid),
//                         selectedFilter: _model.selectedHistoryFilter!,
//                         upcoming: false,
//                         emptComponent: () => NoVisitsWidget(
//                           header: 'No recorded visits',
//                           description: 'Completed visits will appear here',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ]
//                   .divide(SizedBox(height: 16.0))
//                   .addToStart(SizedBox(height: 12.0)),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding:
//                       EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         InkWell(
//                           splashColor: Colors.transparent,
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () async {
//                             _model.selectedUpcomingFilter = VisitFilter.today;
//                             safeSetState(() {});
//                             FFAppState().showIncompleatAlert = true;
//                             safeSetState(() {});
//                           },
//                           child: wrapWithModel(
//                             model: _model.dateFilterModel3,
//                             updateCallback: () => safeSetState(() {}),
//                             child: DateFilterWidget(
//                               index: 0,
//                               selectedIndex: _model.selectedUpcomingFilter ==
//                                       VisitFilter.today
//                                   ? 0
//                                   : -1,
//                               filterText: 'Today',
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           splashColor: Colors.transparent,
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () async {
//                             _model.selectedUpcomingFilter =
//                                 VisitFilter.tomorrow;
//                             safeSetState(() {});
//                             FFAppState().showIncompleatAlert = true;
//                             safeSetState(() {});
//                           },
//                           child: wrapWithModel(
//                             model: _model.dateFilterModel4,
//                             updateCallback: () => safeSetState(() {}),
//                             child: DateFilterWidget(
//                               index: 1,
//                               selectedIndex: _model.selectedUpcomingFilter ==
//                                       VisitFilter.tomorrow
//                                   ? 1
//                                   : -1,
//                               filterText: 'Tomorrow',
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           splashColor: Colors.transparent,
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () async {
//                             _model.selectedUpcomingFilter =
//                                 VisitFilter.next7Days;
//                             safeSetState(() {});
//                             FFAppState().showIncompleatAlert = true;
//                             safeSetState(() {});
//                           },
//                           child: wrapWithModel(
//                             model: _model.dateFilterModel5,
//                             updateCallback: () => safeSetState(() {}),
//                             child: DateFilterWidget(
//                               index: 2,
//                               selectedIndex: _model.selectedUpcomingFilter ==
//                                       VisitFilter.next7Days
//                                   ? 2
//                                   : -1,
//                               filterText: 'Next 7 days',
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           splashColor: Colors.transparent,
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () async {
//                             _model.selectedUpcomingFilter =
//                                 VisitFilter.next14Days;
//                             safeSetState(() {});
//                             FFAppState().showIncompleatAlert = true;
//                             safeSetState(() {});
//                           },
//                           child: wrapWithModel(
//                             model: _model.dateFilterModel6,
//                             updateCallback: () => safeSetState(() {}),
//                             child: DateFilterWidget(
//                               index: 3,
//                               selectedIndex: _model.selectedUpcomingFilter ==
//                                       VisitFilter.next14Days
//                                   ? 3
//                                   : -1,
//                               filterText: 'Next 14 days',
//                             ),
//                           ),
//                         ),
//                       ].divide(SizedBox(width: 8.0)),
//                     ),
//                   ),
//                 ),
//                 Flexible(
//                   child: Container(
//                     width: double.infinity,
//                     child: custom_widgets.PowerSyncQurey(
//                       width: double.infinity,
//                       sql:
//                           'SELECT \n  visits.*, \n   clients.keysafe_code, \n  clients.address, \n  clients.gps_longitude, \n  clients.gps_latitude, \n  clients.nfc_id, \n  clients.name AS client_name \nFROM visits \nLEFT JOIN clients ON visits.client_id = clients.id \nWHERE visits.primary_carer_id = :id OR visits.secondary_carer_id = :id2 \nORDER BY visits.scheduled_start_time ASC;',
//                       parameters: <String, dynamic>{
//                         'id': currentUserUid,
//                         'id2': currentUserUid,
//                       },
//                       enableDebugLogs: false,
//                       refreshTrigger: FFAppState().refreshVisits,
//                       backButtonPress: () async {},
//                       child: (List<dynamic> data) =>
//                           VisitsListWithIncompleteAlertWidget(
//                         visitsData:
//                             functions.convertJsonToVisitsRow(data.toList()),
//                         incompleateVistsIds: functions.getIncompleateVists(
//                             functions
//                                 .convertJsonToVisitsRow(data.toList())
//                                 .toList(),
//                             currentUserUid),
//                         selectedFilter: _model.selectedUpcomingFilter!,
//                         upcoming: true,
//                         emptComponent: () => NoVisitsWidget(
//                           header: 'No upcoming visits',
//                           description: 'Scheduled visits will appear here',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ]
//                   .divide(SizedBox(height: 16.0))
//                   .addToStart(SizedBox(height: 12.0)),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Padding(
//                   padding:
//                       EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.max,
//                     children: [
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           _model.uncoveredSql =
//                               'select * from shifts WHERE visits_number > 0 ORDER BY shift_date ASC;';
//                           _model.uncoverdSelectedFilter = 0;
//                           safeSetState(() {});
//                         },
//                         child: wrapWithModel(
//                           model: _model.dateFilterModel7,
//                           updateCallback: () => safeSetState(() {}),
//                           child: DateFilterWidget(
//                             index: 0,
//                             selectedIndex: _model.uncoverdSelectedFilter!,
//                             filterText: 'Nearest',
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         splashColor: Colors.transparent,
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () async {
//                           _model.uncoveredSql =
//                               'select * from shifts WHERE visits_number > 0 ORDER BY shift_date DESC;';
//                           _model.uncoverdSelectedFilter = 1;
//                           safeSetState(() {});
//                         },
//                         child: wrapWithModel(
//                           model: _model.dateFilterModel8,
//                           updateCallback: () => safeSetState(() {}),
//                           child: DateFilterWidget(
//                             index: 1,
//                             selectedIndex: _model.uncoverdSelectedFilter!,
//                             filterText: 'Latest',
//                           ),
//                         ),
//                       ),
//                     ].divide(SizedBox(width: 8.0)),
//                   ),
//                 ),
//                 Flexible(
//                   child: Container(
//                     width: double.infinity,
//                     child: custom_widgets.PowerSyncQurey(
//                       width: double.infinity,
//                       sql: _model.uncoveredSql,
//                       enableDebugLogs: true,
//                       parameters: <String, dynamic>{
//                         'id': currentUserUid,
//                       },
//                       refreshTrigger: FFAppState().refreshVisits,
//                       backButtonPress: () async {},
//                       child: (List<dynamic> data) => ShiftsListWidget(
//                         shiftsList:
//                             functions.convertJsonToShiftsRow(data.toList()),
//                       ),
//                     ),
//                   ),
//                 ),
//               ]
//                   .divide(SizedBox(height: 16.0))
//                   .addToStart(SizedBox(height: 12.0)),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// )
// ;
//   }
// }
