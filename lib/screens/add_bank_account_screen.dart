import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _accountNoCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _printOnInvoice = false;
  bool _printUPIOnInvoice = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountNoCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Bank Account",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Bank Name / Account Display Name Field
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: "Bank Name/ Account Display Name",
                      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF0284C7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0284C7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0284C7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Optional Account Number Field
                  TextField(
                    controller: _accountNoCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: "Account Number (Optional)",
                      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Opening Balance & As On Row
                  Row(
                    children: [
                      // Opening Balance Field
                      Expanded(
                        child: TextField(
                          controller: _balanceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            labelText: "Opening Balance",
                            hintText: "Opening Balan...",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // As On Date Field
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectAsOnDate(),
                          child: IgnorePointer(
                            child: TextField(
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                              ),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: "As On",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF64748B)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section Blue Strip Backdrop Divider
                  Container(
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: -16),
                    color: const Color(0xFFEBF3FC),
                  ),
                  const SizedBox(height: 16),

                  // 3. Toggle Switch Row 1
                  _buildToggleRow(
                    title: "Print bank details on invoices",
                    value: _printOnInvoice,
                    onChanged: (val) {
                      setState(() {
                        _printOnInvoice = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Toggle Switch Row 2
                  _buildToggleRow(
                    title: "Print UPI QR Code on invoices",
                    value: _printUPIOnInvoice,
                    onChanged: (val) {
                      setState(() {
                        _printUPIOnInvoice = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 5. Save Button (Full Width Sticky Red Button)
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  final accNo = _accountNoCtrl.text.trim();
                  final bal = double.tryParse(_balanceCtrl.text.trim()) ?? 0.0;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bank Account Name cannot be empty")),
                    );
                    return;
                  }

                  // Register account
                  final acc = BankAccount(
                    id: "bank_${DateTime.now().millisecondsSinceEpoch}",
                    name: name,
                    accountNumber: accNo.isNotEmpty ? accNo : "${100000000000 + DateTime.now().millisecondsSinceEpoch % 899999999999}",
                    balance: bal,
                    isCash: false,
                    printOnInvoice: _printOnInvoice,
                    printUPIOnInvoice: _printUPIOnInvoice,
                  );

                  appState.addBankAccount(acc);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Bank Account '$name' registered successfully!"),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48), // Matching red button background
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enables $title feature on print output")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: const Text(
                    "i",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF94A3B8),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFCBD5E1),
        ),
      ],
    );
  }

  Future<void> _selectAsOnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
