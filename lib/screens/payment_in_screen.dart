import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class PaymentInScreen extends StatefulWidget {
  final String? initialPartyId;

  const PaymentInScreen({super.key, this.initialPartyId});

  @override
  State<PaymentInScreen> createState() => _PaymentInScreenState();
}

class _PaymentInScreenState extends State<PaymentInScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPartyId;
  final _amountCtrl = TextEditingController();
  final _receiptNoCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String _paymentMode = "Cash"; // "Cash", "Bank Transfer", "UPI/QR", "Cheque"

  @override
  void initState() {
    super.initState();
    _selectedPartyId = widget.initialPartyId;
    _receiptNoCtrl.text = "REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _receiptNoCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Get active customer balance
    double customerBalance = 0.0;
    if (_selectedPartyId != null) {
      final idx = appState.parties.indexWhere((p) => p.id == _selectedPartyId);
      if (idx != -1) {
        customerBalance = appState.parties[idx].currentBalance;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment In (Receipt)", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded, color: Colors.blue),
            onPressed: () {
              if (_formKey.currentState!.validate() && _selectedPartyId != null) {
                _generateReceiptPdf(appState);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a customer and enter amount to print!"), backgroundColor: AppTheme.accentRed),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Select Customer (Dropdown linked to existing database)
              const Text(
                "Select Customer *",
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
                  hint: const Text("Select Existing Customer"),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
                  ),
                  items: appState.parties.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPartyId = val;
                    });
                  },
                  validator: (val) {
                    if (val == null) return "Selecting a customer is required";
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 6),
              if (_selectedPartyId != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Receivable Balance: ${formatCurrency.format(customerBalance)}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: customerBalance >= 0 ? AppTheme.successGreen : AppTheme.accentRed,
                    ),
                  ),
                ),
              const SizedBox(height: 18),

              // 2. Amount Received
              const Text(
                "Amount Received (₹) *",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              ThreeDContainer(
                depth: 2,
                borderRadius: 14,
                borderWidth: 1,
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                child: TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: "0.00",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppTheme.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter received amount";
                    if (double.tryParse(val) == null || double.parse(val) <= 0) {
                      return "Enter a valid amount greater than 0";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 18),

              // 3. Receipt Details (No, Date)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Receipt No", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        ThreeDContainer(
                          depth: 2,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: TextFormField(
                            controller: _receiptNoCtrl,
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
                        const Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _paymentDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _paymentDate = picked);
                            }
                          },
                          child: ThreeDContainer(
                            depth: 2,
                            borderRadius: 12,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('dd/MM/yyyy').format(_paymentDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Payment Mode Choice
              const Text(
                "Payment Mode",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: ["Cash", "Bank Transfer", "UPI / QR", "Cheque"].map((mode) {
                  final isSel = _paymentMode == mode;
                  return ChoiceChip(
                    label: Text(mode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    selected: isSel,
                    selectedColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: isSel ? Colors.blue.shade800 : Colors.grey.shade700),
                    onSelected: (val) {
                      if (val) setState(() => _paymentMode = mode);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // 5. Remarks
              const Text(
                "Remarks / Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              ThreeDContainer(
                depth: 2,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: TextFormField(
                  controller: _remarksCtrl,
                  decoration: const InputDecoration(
                    hintText: "e.g. Received partial payment against outstanding balance",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // 6. Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded),
                      label: const Text("Print Receipt", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _selectedPartyId != null) {
                          _generateReceiptPdf(appState);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ThreeDButton(
                      height: 50,
                      color: AppTheme.successGreen,
                      text: "Save Payment In",
                      onPressed: () => _savePaymentIn(appState),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePaymentIn(AppState state) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPartyId == null) return;

    final amount = double.parse(_amountCtrl.text.trim());
    final partyIdx = state.parties.indexWhere((p) => p.id == _selectedPartyId);
    if (partyIdx == -1) return;
    final party = state.parties[partyIdx];

    // Create ledger transaction
    final tx = Transaction(
      id: "tx_${DateTime.now().millisecondsSinceEpoch}",
      partyId: _selectedPartyId!,
      partyName: party.name,
      type: TransactionType.paymentIn,
      amount: amount,
      date: _paymentDate,
      description: _remarksCtrl.text.trim().isNotEmpty
          ? _remarksCtrl.text.trim()
          : "Payment received via $_paymentMode. Ref: ${_receiptNoCtrl.text}",
      invoiceNo: _receiptNoCtrl.text.trim(),
    );

    state.addTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Recorded Payment-In of ₹${amount.toStringAsFixed(2)} for ${party.name}!"),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  // Generate Receipt PDF Voucher dialog simulator
  void _generateReceiptPdf(AppState appState) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final partyIdx = appState.parties.indexWhere((p) => p.id == _selectedPartyId);
    final partyName = partyIdx != -1 ? appState.parties[partyIdx].name : "Walk-in Customer";
    final partyPhone = partyIdx != -1 ? appState.parties[partyIdx].phone : "";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Print Receipt Voucher Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appState.businessName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primary)),
                              const Text("Accounts & Ledger Division", style: TextStyle(fontSize: 9, color: Colors.grey)),
                              Text("Ph: 9835013307 • Email: jmd@gmail.com", style: const TextStyle(fontSize: 8, color: Colors.grey)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.green.shade50,
                            child: const Text("PAYMENT RECEIPT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green)),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Receipt Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("RECEIVED FROM:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(partyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              if (partyPhone.isNotEmpty) Text("Ph: $partyPhone", style: const TextStyle(fontSize: 9)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Receipt No: ${_receiptNoCtrl.text}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                              Text("Date: ${DateFormat('dd MMM yyyy').format(_paymentDate)}", style: const TextStyle(fontSize: 9)),
                              Text("Mode: $_paymentMode", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Amount card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TOTAL AMOUNT RECEIVED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            Text(formatCurrency.format(amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.green)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remarks
                      const Text("REMARKS / TRANSACTION DETAILS:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        _remarksCtrl.text.trim().isNotEmpty
                            ? _remarksCtrl.text.trim()
                            : "Received with thanks. Fully acknowledged ledger statement update.",
                        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 40),

                      // Signature row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 50,
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: const Text("RECEIVED\nSTAMP", style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                              ),
                              const SizedBox(height: 2),
                              const Text("Acknowledgment Stamp", style: TextStyle(fontSize: 7, color: Colors.grey)),
                            ],
                          ),
                          const Column(
                            children: [
                              SizedBox(height: 24),
                              Text("Authorized Cashier Signature", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded),
                      label: const Text("Print Receipt"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connecting to Bluetooth print voucher client...")));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: const Text("Share via WhatsApp"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied! Sending confirmation...")));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
