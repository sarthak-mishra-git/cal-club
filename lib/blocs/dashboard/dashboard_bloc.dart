import 'package:bloc/bloc.dart';
import '../../network/dashboard_repository.dart';
import '../../network/health_repository.dart';
import '../../services/health_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;
  final HealthRepository healthRepository;
  
  DashboardBloc({
    required this.repository,
    required this.healthRepository,
  }) : super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<FetchHealthData>(_onFetchHealthData);
    on<ConnectToAppleHealth>(_onConnectToAppleHealth);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final screenModel = await repository.fetchDashboardScreenModel(date: event.date);
      
      // Fetch health data for the same date
      HealthData? healthData;
      HealthConnectionStatus healthStatus = HealthConnectionStatus.notAvailable;
      
      try {
        healthStatus = await healthRepository.getConnectionStatus();
        if (healthStatus == HealthConnectionStatus.connected && event.date != null) {
          final date = DateTime.parse(event.date!);
          healthData = await healthRepository.fetchHealthData(date);
        }
      } catch (e) {
        print('Error fetching health data: $e');
        // Set status to not available on error
        healthStatus = HealthConnectionStatus.notAvailable;
      }
      
      emit(DashboardLoaded(
        screenModel.appBarData, 
        screenModel.weekViewData, 
        screenModel.daySelectorData,
        screenModel.widgets, 
        screenModel.footerData, 
        screenModel.showFloatingActionButton,
        healthData: healthData,
        healthConnectionStatus: healthStatus,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data'));
    }
  }

  Future<void> _onFetchHealthData(
    FetchHealthData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;
    
    final currentState = state as DashboardLoaded;
    
    try {
      final healthStatus = await healthRepository.getConnectionStatus();
      HealthData? healthData;
      
      if (healthStatus == HealthConnectionStatus.connected && event.date != null) {
        final date = DateTime.parse(event.date!);
        healthData = await healthRepository.fetchHealthData(date);
      }
      
      emit(DashboardLoaded(
        currentState.appBarData,
        currentState.weekViewData,
        currentState.daySelectorData,
        currentState.widgets,
        currentState.footerData,
        currentState.showFloatingActionButton,
        healthData: healthData,
        healthConnectionStatus: healthStatus,
      ));
    } catch (e) {
      print('Error fetching health data: $e');
    }
  }

  Future<void> _onConnectToAppleHealth(
    ConnectToAppleHealth event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      print('Requesting Apple Health permissions...');
      await healthRepository.requestHealthPermissions();
      
      // Refresh dashboard to check for new data
      print('Permission dialog completed, refreshing dashboard...');
      add(FetchDashboardData());
    } catch (e) {
      print('Error connecting to Apple Health: $e');
    }
  }
}
