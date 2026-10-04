import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;
  final String? initialPartyId;

  const AddTransactionScreen({
    super.key,
    required this.initialType,
    this.initialPartyId,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  String? _selectedPartyId;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _invoiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedPartyId = widget.initialPartyId;
    _invoiceController.text = "TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Filter parties list
    final filteredParties = appState.parties;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Transaction", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Transaction Type Selector (Segmented buttons)
                const Text(
                  "Transaction Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                _buildTypeSelector(),

                const SizedBox(height: 18),

                // 2. Select Party Dropdown
                if (_type != TransactionType.expense) ...[
                  const Text(
                    "Link to Party / Customer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  ThreeDContainer(
                    depth: 2,
                    borderRadius: 14,
                    borderWidth: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPartyId,
                      hint: const Text("Select Party Profile"),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primary),
                      ),
                      items: filteredParties.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedPartyId = val);
                      },
                      validator: (val) {
                        if (val == null) return "Selecting a party is required";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 3. Amount Field
                const Text(
                  "Transaction Amount (₹)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                ThreeDContainer(
                  depth: 2,
                  borderRadius: 14,
                  borderWidth: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: "0.00",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppTheme.primary),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Enter an amount";
                      if (double.tryParse(val) == null || double.parse(val) <= 0) {
                        return "Enter a valid amount greater than 0";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Invoice / Ref Number & Notes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Invoice/Ref No.",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),
                          ThreeDContainer(
                            depth: 2,
                            borderRadius: 14,
                            borderWidth: 1,
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                            child: TextFormField(
                              controller: _invoiceController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Notes / Remarks",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),
                          ThreeDContainer(
                            depth: 2,
                            borderRadius: 14,
                            borderWidth: 1,
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                hintText: "Optional notes",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // 5. Submit Transaction
                ThreeDButton(
                  color: AppTheme.primary,
                  text: "Submit Ledger Record",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final amount = double.parse(_amountController.text.trim());
                      String partyName = "";

                      if (_type != TransactionType.expense) {
                        final party = appState.parties.firstWhere((p) => p.id == _selectedPartyId);
                        partyName = party.name;
                      } else {
                        partyName = _descriptionController.text.trim().isNotEmpty
                            ? _descriptionController.text.trim()
                            : "Direct Expense";
                      }

                      final tx = Transaction(
                        id: "tx_${DateTime.now().millisecondsSinceEpoch}",
                        partyId: _selectedPartyId ?? "",
                        partyName: partyName,
                        type: _type,
                        amount: amount,
                        date: DateTime.now(),
                        description: _descriptionController.text.trim(),
                        invoiceNo: _invoiceController.text.trim(),
                      );

                      appState.addTransaction(tx);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Recorded ${_type.name.toUpperCase()} of ₹$amount successfully!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Row builder for transaction type switching
  Widget _buildTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransactionType.values.map((type) {
          final isSelected = _type == type;
          final color = type == TransactionType.sale || type == TransactionType.paymentIn
              ? AppTheme.successGreen
              : type == TransactionType.expense
                  ? AppTheme.warningOrange
                  : AppTheme.accentRed;

          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                type == TransactionType.paymentIn
                    ? "PAY IN"
                    : type == TransactionType.paymentOut
                        ? "PAY OUT"
                        : type == TransactionType.saleReturn
                            ? "CREDIT NOTE"
                            : type == TransactionType.purchaseReturn
                                ? "DEBIT NOTE"
                                : type == TransactionType.purchaseOrder
                                    ? "PURCHASE ORDER"
                                    : type.name.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              selected: isSelected,
              selectedColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? color : const Color(0xFF64748B),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _type = type;
                    // Reset selected party if changed to Expense
                    if (type == TransactionType.expense) {
                      _selectedPartyId = null;
                    }
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
