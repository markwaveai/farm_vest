import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_services.dart';
import '../../data/models/animalkart_order_model.dart';

class PaidOrdersData {
  final List<AnimalkartOrder> orders;

  PaidOrdersData({required this.orders});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaidOrdersData && other.orders.length == orders.length;
  }

  @override
  int get hashCode {
    return orders.length.hashCode;
  }
}

class PaidOrdersParams {
  final String? mobile;

  PaidOrdersParams({this.mobile});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaidOrdersParams && other.mobile == mobile;
  }

  @override
  int get hashCode => mobile.hashCode;
}

final paidOrdersProvider =
    FutureProvider.family<PaidOrdersData, PaidOrdersParams>((
      ref,
      params,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final adminMobile = prefs.getString('mobile_number') ?? "";

      final response = await ApiServices.getIntransitOrders(
        mobile: params.mobile.toString(),
        adminMobile: adminMobile,
      );

      return PaidOrdersData(orders: response);
    });
