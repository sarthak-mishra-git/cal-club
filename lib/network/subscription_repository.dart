import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment/plan_model.dart';
import '../models/payment/subscription_model.dart';
import '../utils/network_logger.dart';
import '../network/token_storage.dart';
import '../network/api_client.dart';

class SubscriptionRepository {
  static const String _baseUrl = 'https://calclub.onrender.com';

  Future<PlansResponse> getPlans() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiClient.get(
        '/plans',
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlansResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch plans: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', '$_baseUrl/plans', e.toString());
      rethrow;
    }
  }

  Future<CreateSubscriptionResponse> createSubscription(String externalPlanId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = {
        'external_plan_id': externalPlanId,
      };

      final response = await ApiClient.post(
        '/subscriptions',
        body: body,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CreateSubscriptionResponse.fromJson(data);
      } else {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('POST', '$_baseUrl/subscriptions', e.toString());
      rethrow;
    }
  }

  Future<GetSubscriptionResponse> getSubscription(String subscriptionId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiClient.get(
        '/subscriptions/$subscriptionId',
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GetSubscriptionResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Subscription not found');
      } else {
        throw Exception('Failed to get subscription: ${response.statusCode}');
      }
    } catch (e) {
      NetworkLogger.logError('GET', '$_baseUrl/subscriptions/$subscriptionId', e.toString());
      rethrow;
    }
  }
}
