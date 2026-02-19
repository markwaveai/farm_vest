import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/animalkart_order_model.dart';

class IntransitOrdersData {
  final List<AnimalkartOrder> orders;

  IntransitOrdersData({required this.orders});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntransitOrdersData && other.orders.length == orders.length;
  }

  @override
  int get hashCode {
    return orders.length.hashCode;
  }
}

class IntransitOrdersParams {
  final String? mobile;

  IntransitOrdersParams({this.mobile});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntransitOrdersParams && other.mobile == mobile;
  }

  @override
  int get hashCode => mobile.hashCode;
}

final paidOrdersProvider =
    FutureProvider.family<IntransitOrdersData, IntransitOrdersParams>((
      ref,
      params,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final managerMobile = prefs.getString('mobile_number') ?? "";

      final response = await AnimalApiServices.getIntransitOrders(
        mobile: params.mobile,
        managerMobile: managerMobile,
      );

      return IntransitOrdersData(orders: response);
    });
