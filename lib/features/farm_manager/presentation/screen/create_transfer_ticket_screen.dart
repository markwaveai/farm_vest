import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTransferTicketScreen extends StatefulWidget {
  const CreateTransferTicketScreen({super.key});

  @override
  State<CreateTransferTicketScreen> createState() =>
      _CreateTransferTicketScreenState();
}

class _CreateTransferTicketScreenState
    extends State<CreateTransferTicketScreen> {
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
      ).showSnackBar(const SnackBar(content: Text('Please select an animal')));
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
            const SnackBar(
              content: Text('Transfer ticket created successfully'),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create ticket')),
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
          "Create Transfer Ticket",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Animal Selection"),
              const SizedBox(height: 8),
              if (_selectedAnimalId != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pets, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Selected: $_selectedAnimalRfid",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.green),
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
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
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
                  const SizedBox(height: 8),
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
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
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
              const SizedBox(height: 24),
              _buildSectionTitle("Transfer Details"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _direction,
                decoration: _inputDecoration("Transfer Direction"),
                items: const [
                  DropdownMenuItem(value: 'OUT', child: Text("Moving OUT")),
                  DropdownMenuItem(value: 'IN', child: Text("Moving IN")),
                ],
                onChanged: (val) => setState(() => _direction = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: _inputDecoration("Priority"),
                items: const [
                  DropdownMenuItem(value: 'LOW', child: Text("Low")),
                  DropdownMenuItem(value: 'MEDIUM', child: Text("Medium")),
                  DropdownMenuItem(value: 'HIGH', child: Text("High")),
                  DropdownMenuItem(value: 'URGENT', child: Text("Urgent")),
                ],
                onChanged: (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hint: "Reason for transfer...",
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 32),
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
