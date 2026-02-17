import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class CreateTransferTicketScreen extends ConsumerStatefulWidget {
  CreateTransferTicketScreen({super.key});

  @override
  State<CreateTransferTicketScreen> createState() =>
      _CreateTransferTicketScreenState();
}

class _CreateTransferTicketScreenState extends ConsumerState<CreateTransferTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _animalSearchController = TextEditingController();

  String _direction = 'OUT'; // IN or OUT
  String? _selectedAnimalId;
  String? _selectedAnimalRfid;
  String _priority = 'LOW'; // LOW, MEDIUM, HIGH, URGENT

  bool _isSubmitting = false;
  bool _isSearching = false;
  List<InvestorAnimal> _searchResults = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _animalSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchAnimal(String query) async {
    if (query.length < 3) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final results = await AnimalApiServices.searchAnimals(
        token: token,
        query: query,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnimalId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an animal'.tr(ref))));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final body = {
        "animal_id": _selectedAnimalId,
        "transfer_direction": _direction,
        "description": _descriptionController.text,
        "priority": _priority,
      };

      final success = await TicketsApiServices.createTransferTicket(
        token: token,
        body: body,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transfer ticket created successfully'.tr(ref)),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create ticket'.tr(ref))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Create Transfer Ticket".tr(ref),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Animal Selection"),
              SizedBox(height: 8),
              if (_selectedAnimalId != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pets, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Selected: $_selectedAnimalRfid",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _selectedAnimalId = null;
                            _selectedAnimalRfid = null;
                            _searchResults = [];
                            _animalSearchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _animalSearchController,
                  decoration: InputDecoration(
                    hintText: "Search RFID / Ear Tag",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _isSearching
                        ? Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    if (val.length >= 3) {
                      _searchAnimal(val);
                    } else {
                      setState(() => _searchResults = []);
                    }
                  },
                ),
                if (_searchResults.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (c, i) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final animal = _searchResults[index];
                        final rfid =
                            animal.rfid ?? animal.animalId ?? 'Unknown';
                        return ListTile(
                          title: Text("RFID: $rfid"),
                          subtitle: Text("Shed: ${animal.shedName ?? 'None'}"),
                          onTap: () {
                            setState(() {
                              _selectedAnimalId =
                                  (animal.internalId ?? animal.animalId)
                                      .toString();
                              _selectedAnimalRfid = rfid;
                              _searchResults = [];
                              _animalSearchController.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
              SizedBox(height: 24),
              _buildSectionTitle("Transfer Details"),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _direction,
                decoration: _inputDecoration("Transfer Direction"),
                items: [
                  DropdownMenuItem(value: 'OUT', child: Text("Moving OUT".tr(ref))),
                  DropdownMenuItem(value: 'IN', child: Text("Moving IN".tr(ref))),
                ],
                onChanged: (val) => setState(() => _direction = val!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: _inputDecoration("Priority"),
                items: [
                  DropdownMenuItem(value: 'LOW', child: Text("Low".tr(ref))),
                  DropdownMenuItem(value: 'MEDIUM', child: Text("Medium".tr(ref))),
                  DropdownMenuItem(value: 'HIGH', child: Text("High".tr(ref))),
                  DropdownMenuItem(value: 'URGENT', child: Text("Urgent".tr(ref))),
                ],
                onChanged: (val) => setState(() => _priority = val!),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hint: "Reason for transfer...",
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? "Description is required" : null,
              ),
              SizedBox(height: 32),
              PrimaryButton(
                text: "Create Ticket",
                onPressed: _submitTicket,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.02)
          : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.grey[300]!,
        ),
      ),
    );
  }
}
