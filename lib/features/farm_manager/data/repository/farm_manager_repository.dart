import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_enums.dart';
import '../models/health_transfer_ticket_model.dart';

class FarmManagerRepository {
  Future<List<HealthTransferTicketModel>> getHealthAndTransferTickets({
    required String ticketType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw AuthException('Authentication token not found');
    }

    return await ApiServices.getHealthAndTransferTickets(ticketType, token);
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw AuthException('Authentication token not found');
    }

    await ApiServices.updateTicketStatus(
      ticketId,
      status.name.toUpperCase(),
      token,
    );
  }
}
