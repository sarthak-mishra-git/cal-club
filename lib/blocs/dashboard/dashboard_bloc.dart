import 'package:bloc/bloc.dart';
import '../../network/dashboard_repository.dart';
import '../../models/screens/dashboard_screen_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;
  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final screenModel = await repository.fetchDashboardScreenModel(date: event.date);
      emit(DashboardLoaded(screenModel.appBarData, screenModel.weekViewData, screenModel.widgets, screenModel.footerData, screenModel.showFloatingActionButton));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data'));
    }
  }
}
