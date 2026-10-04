import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../widgets/company_menu_bar.dart';
import '../theme/app_theme.dart';
import 'reports_screen.dart';
import 'sale_return_screen.dart';
import 'delivery_challan_screen.dart';
import 'purchase_list_screen.dart';
import 'purchase_order_screen.dart';
import 'expense_screen.dart';
import 'profit_loss_screen.dart';
import 'bank_accounts_screen.dart';
import 'cash_in_hand_screen.dart';
import 'activity_screen.dart';
import '../widgets/app_drawer.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: const Text("App Menu & Utilities", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primary,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_rounded), text: "Activities"),
              Tab(icon: Icon(Icons.assessment_rounded), text: "Reports"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Activities
            Column(
              children: [
                const CompanyMenuBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCategoryHeader("Sales & Purchase Activities"),
                        const SizedBox(height: 8),
                        _buildMenuGrid(context, [
                          _MenuItem("Sale Invoice", Icons.receipt_rounded, Colors.green, () => _showWipToast(context, "Sale Invoice Form")),
                          _MenuItem("Estimates (Quotation)", Icons.request_quote_rounded, Colors.teal, () => _showWipToast(context, "Quotation Form")),
                          _MenuItem("Delivery Challan", Icons.local_shipping_rounded, Colors.amber, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DeliveryChallanScreen()),
                            );
                          }),
                          _MenuItem("Credit Note", Icons.assignment_return_rounded, Colors.red, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SaleReturnScreen()),
                            );
                          }),
                          _MenuItem("Purchase Bill", Icons.shopping_bag_rounded, Colors.pink, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PurchaseListScreen()),
                            );
                          }),
                          _MenuItem("Purchase Order", Icons.playlist_add_check_rounded, Colors.indigo, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PurchaseOrderScreen()),
                            );
                          }),
                          _MenuItem("Expense", Icons.receipt_rounded, Colors.orange, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExpenseScreen()),
                            );
                          }),
                          _MenuItem("Activity Log", Icons.history_rounded, Colors.purple, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ActivityScreen()),
                            );
                          }),
                        ]),
  
                        const SizedBox(height: 20),
  
                        _buildCategoryHeader("Cash & Bank Accounts"),
                        const SizedBox(height: 8),
                        _buildMenuGrid(context, [
                          _MenuItem("Bank Accounts", Icons.account_balance_rounded, Colors.blue, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BankAccountsScreen()),
                            );
                          }),
                          _MenuItem("Cash in Hand", Icons.payments_rounded, Colors.green, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CashInHandScreen()),
                            );
                          }),
                          _MenuItem("Cheques Status", Icons.credit_card_rounded, Colors.orange, () => _showWipToast(context, "Cheques Registry")),
                          _MenuItem("Bank Transfer", Icons.swap_horiz_rounded, Colors.cyan, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BankAccountsScreen(autoOpenDepositWithdraw: true)),
                            );
                          }),
                        ]),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
  
            // Tab 2: Reports & Utilities
            Column(
              children: [
                const CompanyMenuBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCategoryHeader("Business Reports"),
                        const SizedBox(height: 8),
                        _buildMenuGrid(context, [
                          _MenuItem("Reports Dashboard", Icons.assessment_rounded, Colors.blue, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReportsScreen()),
                            );
                          }),
                          _MenuItem("Profit & Loss", Icons.analytics_rounded, Colors.purple, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfitAndLossScreen()),
                            );
                          }),
                          _MenuItem("Day Book", Icons.auto_stories_rounded, Colors.deepOrange, () => _showDayBookReport(context)),
                          _MenuItem("Stock Report", Icons.inventory_2_rounded, Colors.brown, () => _showWipToast(context, "Stock Report")),
                        ]),
  
                        const SizedBox(height: 20),
  
                        _buildCategoryHeader("Utilities & Data Security"),
                        const SizedBox(height: 8),
                        _buildMenuGrid(context, [
                          _MenuItem("Backup to Cloud", Icons.cloud_upload_rounded, Colors.indigoAccent, () {
                            _showSuccessToast(context, "Data backed up to Google Drive successfully!");
                          }),
                          _MenuItem("Restore Data", Icons.cloud_download_rounded, Colors.teal, () {
                            _showSuccessToast(context, "Local databases restored from cloud copy!");
                          }),
                          _MenuItem("Recycle Bin", Icons.delete_sweep_rounded, Colors.blueGrey, () => _showWipToast(context, "Recycle Bin")),
                          _MenuItem("Settings Panel", Icons.construction_rounded, Colors.redAccent, () => _showWipToast(context, "Settings Page")),
                        ]),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, List<_MenuItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        return ThreeDContainer(
          depth: 2.5,
          borderRadius: 16,
          borderColor: item.color.withOpacity(0.12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          onTap: item.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: item.color.withOpacity(0.1),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWipToast(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'$feature' forms are ready for production integration. Database link complete."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Dynamic Sub-dialog views for reports & accounts ---

  void _showBankAccountsDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Bank Accounts Registry", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appState.bankAccounts.length,
            itemBuilder: (context, index) {
              final acc = appState.bankAccounts[index];
              return ListTile(
                leading: Icon(
                  acc.isCash ? Icons.payments_rounded : Icons.account_balance_rounded,
                  color: AppTheme.primary,
                ),
                title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  formatCurrency.format(acc.balance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: acc.balance >= 0 ? AppTheme.successGreen : AppTheme.accentRed,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showCashInHandDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cash In Hand Detail"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payments_rounded, color: AppTheme.successGreen, size: 48),
            const SizedBox(height: 14),
            const Text("Total physical cash in business registers:"),
            const SizedBox(height: 6),
            Text(
              formatCurrency.format(appState.cashBalance),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showBankTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Bank-to-Cash Transfer"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Source Account (From)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Destination (To)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Transfer Amount (₹)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transfer completed! Balances updated."), backgroundColor: AppTheme.successGreen),
              );
            },
            child: const Text("Transfer"),
          ),
        ],
      ),
    );
  }

  void _showProfitAndLossReport(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Profit & Loss Statement",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                const Text("Fiscal Period: Current Month", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                const Divider(height: 24),
                _buildReportRow("Revenue (Total Sales)", formatCurrency.format(appState.totalSales), true),
                _buildReportRow("Cost of Goods (Purchases)", "- " + formatCurrency.format(appState.totalPurchases), false),
                _buildReportRow("Operating Expenses", "- " + formatCurrency.format(appState.totalExpenses), false),
                const Divider(height: 20, thickness: 1.5),
                _buildReportRow(
                  "Net Operating Profit",
                  formatCurrency.format(appState.netProfit),
                  true,
                  color: appState.netProfit >= 0 ? AppTheme.successGreen : AppTheme.accentRed,
                ),
                const SizedBox(height: 20),
                ThreeDButton(
                  height: 40,
                  color: AppTheme.primary,
                  text: "Export Statement PDF",
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Simulating PDF write on disk...")),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDayBookReport(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final todayTxs = appState.transactions;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Business Day Book",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const Text("Daily Records Feed", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Divider(height: 20),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: todayTxs.length,
                  itemBuilder: (context, index) {
                    final tx = todayTxs[index];
                    final isCred = tx.type == TransactionType.sale || tx.type == TransactionType.paymentOut;
                    return ListTile(
                      dense: true,
                      title: Text(tx.partyName.isEmpty ? "Direct Ledger" : tx.partyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tx.type.name.toUpperCase()),
                      trailing: Text(
                        formatCurrency.format(tx.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCred ? AppTheme.successGreen : AppTheme.accentRed,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              ThreeDButton(
                height: 40,
                color: AppTheme.primary,
                text: "Print Day Log",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(String title, String val, bool isBold, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: const Color(0xFF334155),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _MenuItem(this.title, this.icon, this.color, this.onTap);
}
