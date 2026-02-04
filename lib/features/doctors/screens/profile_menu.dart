import 'package:flutter/services.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';


class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Umasankar');
  final _emailController = TextEditingController(text: 'umaa@markwave.ai');
  final _phoneController = TextEditingController(text: '6305447441');
  final _addressController =
      TextEditingController(text: 'Westgodavari district, Andhra Pradesh');
  final _dateController = TextEditingController(text: '30/01/2026');

  static const Color orange = Color(0xFFFCA222);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: size.width * 0.75, // ✅ SIDE DRAWER WIDTH
        height: size.height,
        child: Container(
          color: AppTheme.primary,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              30,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 BACK + LOGO (SAME ROW)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/farmvestlogo(1).png',
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // PROFILE HEADER
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 26,
                            color: Color(0xFF30572B),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Umasankar',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          'umaa@markwave.ai',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _label('Full Name'),
                  _inputField(
                    _nameController,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Full name required';
                      }
                      if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) {
                        return 'Only letters allowed';
                      }
                      return null;
                    },
                  ),

                  _label('Email'),
                  _inputField(
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-z0-9@._]'),
                      ),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email required';
                      }
                      if (v != v.toLowerCase()) {
                        return 'Only lowercase letters allowed';
                      }
                      if (!RegExp(
                        r'^[a-z0-9._]+@[a-z0-9]+\.[a-z]{2,}$',
                      ).hasMatch(v)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                _label('Phone'),
                  _inputField(
                    _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Phone number required';
                      }
                      if (v.length != 10) {
                        return 'Enter valid 10 digit number';
                      }
                      return null;
                    },
                  ),


                  _label('Address'),
                  _inputField(
                    _addressController,
                    maxLines: 2,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Address required';
                      }
                      return null;
                    },
                  ),

                  _label('As a User Since'),
                  _inputField(
                    _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select date' : null,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Inventory',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _simpleRow(title: 'Buffalo Profile'),

                  const SizedBox(height: 20),

                  _menuItem(
                    icon: Icons.swap_horiz,
                    title: 'Switch Role',
                    subtitle: 'Currently as Investor',
                  ),
                  _menuItem(
                    icon: Icons.lock_outline,
                    title: 'App Lock',
                    subtitle: 'Use biometric to unlock the app',
                  ),
                  _menuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Disabled',
                  ),
                  _menuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                  ),

                  const SizedBox(height: 24),

                  // LOGOUT
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // logout
                          }
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== HELPERS =====

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      );

  Widget _inputField(
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.75),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          errorStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleRow({required String title}) => Text(
        title,
        style: const TextStyle(color: Colors.white),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }
}
