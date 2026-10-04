import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'bank_accounts_screen.dart';

class CashInHandScreen extends StatefulWidget {
  const CashInHandScreen({super.key});

  @override
  State<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends State<CashInHandScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

  // Sample static cash transactions feed to match screenshot reference
  final List<Map<String, dynamic>> _sampleCashTxFeed = [
    {
      "title": "Payment-in - rajeshwar yadav",
      "date": "18 Jul 2026 • 10:50 AM",
      "amount": 2000.0,
      "isIn": true,
    },
    {
      "title": "Payment-out - Miri Books International",
      "date": "14 Jul 2026 • 01:42 PM",
      "amount": 50000.0,
      "isIn": false,
    },
    {
      "title": "Payment-in - Public education center",
      "date": "13 Jul 2026 • 07:31 PM",
      "amount": 14000.0,
      "isIn": true,
    },
    {
      "title": "Payment-in - krishna sir",
      "date": "13 Jul 2026 • 07:31 PM",
      "amount": 10000.0,
      "isIn": true,
    },
    {
      "title": "Payment-in - ashok sir",
      "date": "13 Jul 2026 • 07:31 PM",
      "amount": 6000.0,
      "isIn": true,
    },
    {
      "title": "Payment-in - Kameshwar sir",
      "date": "09 Jul 2026 • 05:22 PM",
      "amount": 10000.0,
      "isIn": true,
    },
    {
      "title": "Payment-in - Modern english school",
      "date": "09 Jul 2026 • 05:22 PM",
      "amount": 10000.0,
      "isIn": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final formattedCashBal = NumberFormat('#,##,##0.00', 'en_IN').format(appState.cashBalance.abs());
    final isNegative = appState.cashBalance < 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cash In-Hand",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
                  // 1. Current Cash Balance Card (Mint green backdrop)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EE), // Mint green matching screenshot
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Current Cash Balance",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isNegative ? "- ₹ $formattedCashBal" : "₹ $formattedCashBal",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isNegative ? const Color(0xFFE11D48) : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            color: Color(0xFF059669),
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Transaction Details Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Transaction Details",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        "Amount",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // 3. Transactions List Feed
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sampleCashTxFeed.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = _sampleCashTxFeed[index];
                      final isIn = item["isIn"] as bool;
                      final amt = item["amount"] as double;
                      final formattedAmt = NumberFormat('#,##,##0.00', 'en_IN').format(amt);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["title"] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item["date"] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "₹ $formattedAmt",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isIn ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      // 4. Sticky Bottom Actions Bar (Bank Transfer & Adjust Cash)
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left: Bank Transfer (Outlined Red Pill Button)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BankAccountsScreen(autoOpenDepositWithdraw: true),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      foregroundColor: const Color(0xFFE11D48),
                    ),
                    child: const Text(
                      "Bank Transfer",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Right: Adjust Cash (Filled Red Pill Button)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showAdjustCashDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Adjust Cash",
                      style: TextStyle(
                        fontSize: 14,
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
    );
  }

  // --- Adjust Cash Dialog ---
  void _showAdjustCashDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    bool isAdd = true;
    final amountCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Adjust Cash Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Add Cash"),
                        selected: isAdd,
                        selectedColor: Colors.green.shade100,
                        onSelected: (val) => setState(() => isAdd = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Reduce Cash"),
                        selected: !isAdd,
                        selectedColor: Colors.red.shade100,
                        onSelected: (val) => setState(() => isAdd = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Adjustment Amount (₹)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: remarkCtrl,
                  decoration: const InputDecoration(
                    labelText: "Remarks / Reason (Optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
                onPressed: () {
                  final amt = double.tryParse(amountCtrl.text) ?? 0;
                  if (amt <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enter a valid amount")),
                    );
                    return;
                  }

                  appState.adjustCashBalance(amount: amt, isAdd: isAdd);

                  // Add entry to feed locally
                  setState(() {
                    _sampleCashTxFeed.insert(0, {
                      "title": "${isAdd ? 'Cash Add' : 'Cash Reduce'} - ${remarkCtrl.text.trim().isEmpty ? 'Adjustment' : remarkCtrl.text.trim()}",
                      "date": DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.now()),
                      "amount": amt,
                      "isIn": isAdd,
                    });
                  });

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cash balance adjusted by ₹$amt successfully!"),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
