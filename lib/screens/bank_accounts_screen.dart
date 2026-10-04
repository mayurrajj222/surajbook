import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'add_bank_account_screen.dart';
import 'cash_in_hand_screen.dart';

class BankAccountsScreen extends StatefulWidget {
  final bool autoOpenDepositWithdraw;
  const BankAccountsScreen({super.key, this.autoOpenDepositWithdraw = false});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

  @override
  void initState() {
    super.initState();
    if (widget.autoOpenDepositWithdraw) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDepositWithdrawBottomSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allAccounts = appState.bankAccounts;

    return Scaffold(
      backgroundColor: const Color(0xFFEBF3FC), // Soft blue background like reference image
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bank Accounts List",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: allAccounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_outlined, size: 64, color: Colors.blue.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No Bank or Cash Accounts Added Yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap 'Add Bank' below to record your balances.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: allAccounts.length,
              itemBuilder: (context, index) {
                final account = allAccounts[index];
                return _buildAccountCard(context, account);
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xFFEBF3FC),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 1. Add Bank (Outlined Red Button)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddBankAccountScreen()),
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
                      "Add Bank",
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
              // 2. Deposit / Withdraw (Filled Red Button)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showDepositWithdrawBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Deposit / Withdraw",
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

  Widget _buildAccountCard(BuildContext context, BankAccount bank) {
    final isNegative = bank.balance < 0;
    final formattedBalance = isNegative
        ? "- ₹ ${NumberFormat('#,##,##0.00', 'en_IN').format(bank.balance.abs())}"
        : "₹ ${NumberFormat('#,##,##0.00', 'en_IN').format(bank.balance)}";

    final displayName = bank.isCash ? "Cash in Hand" : bank.name;
    final displaySubtitle = bank.isCash ? bank.name : bank.accountNumber;

    return InkWell(
      onTap: bank.isCash
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CashInHandScreen()),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Name and Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                formattedBalance,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Subtitle
          if (displaySubtitle.isNotEmpty)
            Text(
              displaySubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),

          const SizedBox(height: 14),

          // Bottom Row: Badges & Share Icon
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (bank.isCash)
                      _buildBadge("CASH REGISTER")
                    else ...[
                      if (bank.printUPIOnInvoice) _buildBadge("ONLINE PAYMENT"),
                      if (bank.printOnInvoice) _buildBadge("PRINTING"),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.reply_outlined, color: Color(0xFF64748B), size: 22),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sharing details for $displayName...")),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // --- Deposit / Withdraw Modal Bottom Sheet (Image 3) ---

  void _showDepositWithdrawBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                  children: [
                    _buildTransferActionTile(
                      ctx,
                      title: "Bank to Cash\nTransfer",
                      leftIcon: Icons.account_balance,
                      rightIcon: Icons.payments,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showBankToCashDialog(context);
                      },
                    ),
                    _buildTransferActionTile(
                      ctx,
                      title: "Cash to Bank\nTransfer",
                      leftIcon: Icons.payments,
                      rightIcon: Icons.account_balance,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCashToBankDialog(context);
                      },
                    ),
                    _buildTransferActionTile(
                      ctx,
                      title: "Bank to Bank\nTransfer",
                      leftIcon: Icons.account_balance,
                      rightIcon: Icons.account_balance,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showBankToBankDialog(context);
                      },
                    ),
                    _buildTransferActionTile(
                      ctx,
                      title: "Adjust Bank\nBalance",
                      leftIcon: Icons.account_balance,
                      rightIcon: Icons.currency_rupee,
                      isAdjust: true,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showAdjustBalanceDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransferActionTile(
    BuildContext context, {
    required String title,
    required IconData leftIcon,
    required IconData rightIcon,
    required VoidCallback onTap,
    bool isAdjust = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F7FF),
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(leftIcon, size: 20, color: const Color(0xFF1E3A8A)),
                const SizedBox(width: 2),
                Icon(isAdjust ? Icons.swap_vert_rounded : Icons.arrow_forward_rounded, size: 14, color: const Color(0xFF1E3A8A)),
                const SizedBox(width: 2),
                Icon(rightIcon, size: 20, color: const Color(0xFF1E3A8A)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // --- Dialog 1: Bank to Cash Transfer ---
  void _showBankToCashDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final banks = appState.bankAccounts.where((acc) => !acc.isCash).toList();

    if (banks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Bank Accounts available to transfer from.")),
      );
      return;
    }

    String selectedBankId = banks.first.id;
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Bank to Cash Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBankId,
                  decoration: const InputDecoration(
                    labelText: "Select Bank Account",
                    border: OutlineInputBorder(),
                  ),
                  items: banks.map((b) {
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text("${b.name} (Bal: ${formatCurrency.format(b.balance)})"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedBankId = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Transfer Amount (₹)",
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
                  appState.bankToCashTransfer(bankId: selectedBankId, amount: amt);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully transferred ₹$amt from Bank to Cash!"),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text("Transfer", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Dialog 2: Cash to Bank Transfer ---
  void _showCashToBankDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final banks = appState.bankAccounts.where((acc) => !acc.isCash).toList();

    if (banks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Bank Accounts available to deposit into.")),
      );
      return;
    }

    String selectedBankId = banks.first.id;
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Cash to Bank Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Cash Balance: ${formatCurrency.format(appState.cashBalance)}",
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedBankId,
                  decoration: const InputDecoration(
                    labelText: "Select Destination Bank Account",
                    border: OutlineInputBorder(),
                  ),
                  items: banks.map((b) {
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text("${b.name} (${formatCurrency.format(b.balance)})"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedBankId = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Deposit Amount (₹)",
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
                  appState.cashToBankTransfer(bankId: selectedBankId, amount: amt);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully deposited ₹$amt from Cash to Bank!"),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text("Deposit", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Dialog 3: Bank to Bank Transfer ---
  void _showBankToBankDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final banks = appState.bankAccounts.where((acc) => !acc.isCash).toList();

    if (banks.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need at least 2 bank accounts to do a Bank to Bank transfer.")),
      );
      return;
    }

    String fromBankId = banks[0].id;
    String toBankId = banks[1].id;
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Bank to Bank Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: fromBankId,
                  decoration: const InputDecoration(
                    labelText: "From Bank Account",
                    border: OutlineInputBorder(),
                  ),
                  items: banks.map((b) {
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text(b.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => fromBankId = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: toBankId,
                  decoration: const InputDecoration(
                    labelText: "To Bank Account",
                    border: OutlineInputBorder(),
                  ),
                  items: banks.map((b) {
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text(b.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => toBankId = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Transfer Amount (₹)",
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
                  if (fromBankId == toBankId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Source and Destination accounts must be different")),
                    );
                    return;
                  }
                  appState.bankToBankTransfer(fromBankId: fromBankId, toBankId: toBankId, amount: amt);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Transferred ₹$amt between accounts successfully!"),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text("Transfer", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Dialog 4: Adjust Bank Balance ---
  void _showAdjustBalanceDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final banks = appState.bankAccounts.where((acc) => !acc.isCash).toList();

    if (banks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Bank Accounts available to adjust.")),
      );
      return;
    }

    String selectedBankId = banks.first.id;
    bool isAdd = true;
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Adjust Bank Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBankId,
                  decoration: const InputDecoration(
                    labelText: "Select Bank Account",
                    border: OutlineInputBorder(),
                  ),
                  items: banks.map((b) {
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text("${b.name} (${formatCurrency.format(b.balance)})"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedBankId = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Add Money"),
                        selected: isAdd,
                        selectedColor: Colors.green.shade100,
                        onSelected: (val) => setState(() => isAdd = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Reduce Money"),
                        selected: !isAdd,
                        selectedColor: Colors.red.shade100,
                        onSelected: (val) => setState(() => isAdd = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Adjustment Amount (₹)",
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
                  appState.adjustBankBalance(bankId: selectedBankId, amount: amt, isAdd: isAdd);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Adjusted balance by ₹$amt successfully!"),
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
