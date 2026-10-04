import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class AddPartyDialog extends StatefulWidget {
  const AddPartyDialog({super.key});

  @override
  State<AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends State<AddPartyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _balanceController = TextEditingController();
  PartyType _selectedType = PartyType.youWillGet;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Bar Indicator
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create New Party Ledger",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Party Name Field
              _buildTextField(
                controller: _nameController,
                label: "Party / Customer Name",
                icon: Icons.person_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Name is required";
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone Field
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Phone number is required";
                  if (val.trim().length < 10) return "Enter a valid phone number";
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email Field (Optional)
              _buildTextField(
                controller: _emailController,
                label: "Email Address (Optional)",
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Address Field (Optional)
              _buildTextField(
                controller: _addressController,
                label: "Business Address (Optional)",
                icon: Icons.location_on_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Opening Balance Field & Type Selector Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildTextField(
                      controller: _balanceController,
                      label: "Opening Bal. (₹)",
                      icon: Icons.account_balance_wallet_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Balance Type",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // You'll Get selector
                            Expanded(
                              child: ChoiceChip(
                                label: const Text("GET", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                selected: _selectedType == PartyType.youWillGet,
                                selectedColor: const Color(0xFFD1FAE5),
                                labelStyle: TextStyle(
                                  color: _selectedType == PartyType.youWillGet ? AppTheme.successGreen : Colors.grey[700],
                                ),
                                onSelected: (selected) {
                                  if (selected) setState(() => _selectedType = PartyType.youWillGet);
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            // You'll Give selector
                            Expanded(
                              child: ChoiceChip(
                                label: const Text("GIVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                selected: _selectedType == PartyType.youWillGive,
                                selectedColor: const Color(0xFFFFE4E6),
                                labelStyle: TextStyle(
                                  color: _selectedType == PartyType.youWillGive ? AppTheme.accentRed : Colors.grey[700],
                                ),
                                onSelected: (selected) {
                                  if (selected) setState(() => _selectedType = PartyType.youWillGive);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Create Party Button
              ThreeDButton(
                color: AppTheme.primary,
                text: "Save Party Profile",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final balanceVal = double.tryParse(_balanceController.text.trim()) ?? 0.0;
                    final newParty = Party(
                      id: "p_${DateTime.now().millisecondsSinceEpoch}",
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      email: _emailController.text.trim(),
                      address: _addressController.text.trim(),
                      openingBalance: balanceVal,
                      currentBalance: balanceVal,
                      type: _selectedType,
                    );
                    appState.addParty(newParty);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Party '${newParty.name}' added successfully!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return ThreeDContainer(
      depth: 2,
      borderRadius: 14,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          icon: Icon(icon, color: AppTheme.primary, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
