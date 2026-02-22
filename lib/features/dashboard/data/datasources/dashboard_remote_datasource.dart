/// Dashboard Remote Data Source.
library;

import 'package:dio/dio.dart';
import 'package:mockmate/core/constants/api_endpoints.dart';
import 'package:mockmate/core/network/dio_client.dart';
import 'package:mockmate/features/dashboard/data/models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<List<SessionHistoryModel>> getHistory();
  Future<AnalyticsModel> getAnalytics();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;
  const DashboardRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<SessionHistoryModel>> getHistory() async {
    try {
      final response = await _dio.get(ApiEndpoints.history);
      final list = (response.data as List)
          .map((h) => SessionHistoryModel.fromJson(h as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<AnalyticsModel> getAnalytics() async {
    try {
      final response = await _dio.get(ApiEndpoints.analytics);
      return AnalyticsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // If backend not available, return mock data for demo purposes
      if (e.type == DioExceptionType.connectionError) {
        return AnalyticsModel.mock();
      }
      throw handleDioException(e);
    }
  }
}
