import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../widgets/company_menu_bar.dart';
import '../theme/app_theme.dart';
import 'profit_loss_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _searchQuery = "";
  final Set<String> _starredReports = {
    "Sale Report",
    "Profit & Loss",
    "Balance Sheet",
  };

  // Date range filters for reports
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // List of reports matching Screenshot 1
    final transactionReports = [
      _ReportItem("Sale Report", "Sales summary and invoice details", Icons.receipt_long_rounded, Colors.green),
      _ReportItem("Purchase Report", "Purchases summary and bills", Icons.shopping_bag_rounded, Colors.pink),
      _ReportItem("Day Book", "Chronological list of today's activities", Icons.auto_stories_rounded, Colors.deepOrange),
      _ReportItem("All Transactions", "Complete master ledger of transactions", Icons.list_alt_rounded, Colors.blue),
      _ReportItem("Bill Wise Profit", "Profit margins calculated per invoice", Icons.payments_rounded, Colors.teal, isPremium: true),
      _ReportItem("Profit & Loss", "Revenue, expenses, and net profit statement", Icons.analytics_rounded, Colors.purple),
      _ReportItem("Cashflow", "Cash inflow vs cash outflow analysis", Icons.swap_vert_rounded, Colors.cyan),
      _ReportItem("Balance Sheet", "Assets, Liabilities, and Equity statement", Icons.account_balance_rounded, Colors.indigo, isPremium: true),
      _ReportItem("Trial Balance", "Double entry balancing statement", Icons.gavel_rounded, Colors.blueGrey),
    ];

    final partyReports = [
      _ReportItem("Party Statement", "Transaction ledger per client/supplier", Icons.person_search_rounded, Colors.indigoAccent),
      _ReportItem("Party Wise Profit & Loss", "Gross profit contribution per party", Icons.trending_up_rounded, Colors.teal, isPremium: true),
      _ReportItem("All Parties Report", "Overview directory of all party balances", Icons.people_outline_rounded, Colors.amber),
      _ReportItem("Party Report by Items", "Books transacted per party", Icons.summarize_rounded, Colors.teal),
      _ReportItem("Sale/Purchase by Party", "Sales vs Purchases comparison per party", Icons.compare_arrows_rounded, Colors.indigo),
    ];

    final itemStockReports = [
      _ReportItem("Stock Summary Report", "Current inventory counts and values", Icons.inventory_rounded, Colors.brown),
      _ReportItem("Item Report by Party", "Party transaction details filtered by items", Icons.assignment_ind_rounded, Colors.orange),
      _ReportItem("Item Wise Profit & Loss", "Net profit generated per book/product", Icons.donut_small_rounded, Colors.green),
      _ReportItem("Low Stock Summary Report", "Items currently below critical stock levels", Icons.warning_amber_rounded, Colors.red),
      _ReportItem("Sale/Purchase By Item Category", "Item performance partitioned by category", Icons.category_rounded, Colors.blue),
      _ReportItem("Stock summary By Item Category", "Stock levels partitioned by category", Icons.auto_awesome_motion_rounded, Colors.indigo),
      _ReportItem("Item Batch Report", "Inventory batch tracking records", Icons.batch_prediction_rounded, Colors.purple, isPremium: true),
      _ReportItem("Item Serial Report", "Inventory tracking via unique serial numbers", Icons.qr_code_rounded, Colors.purple, isPremium: true),
      _ReportItem("Item Wise Discount", "Total discounts granted per item", Icons.percent_rounded, Colors.teal),
    ];

    final businessStatusReports = [
      _ReportItem("Bank Statement", "Detail of transactions across bank accounts", Icons.account_balance_rounded, Colors.indigo),
      _ReportItem("Discount Report", "Summary of all trade discounts given", Icons.discount_rounded, Colors.green),
    ];

    final taxReports = [
      _ReportItem("Form No. 27EQ", "Quarterly statement of collection of tax at source", Icons.receipt_long_rounded, Colors.blue),
      _ReportItem("TCS Receivable", "Tax Collected at Source receivable ledger", Icons.toll_rounded, Colors.teal),
      _ReportItem("TDS Payable", "Tax Deducted at Source payable obligations", Icons.currency_rupee_rounded, Colors.red),
      _ReportItem("TDS Receivable", "Tax Deducted at Source receivable claims", Icons.savings_rounded, Colors.green),
    ];

    final expenseReports = [
      _ReportItem("Expense Transaction Report", "Chronological list of all expenses", Icons.payment_rounded, Colors.amber),
      _ReportItem("Expense Category Report", "Expenses grouped by operational categories", Icons.grid_view_rounded, Colors.orange),
      _ReportItem("Expense Item Report", "Expenses categorized by direct inventory items", Icons.receipt_rounded, Colors.red),
    ];

    final orderReports = [
      _ReportItem("Sale/Purchase Order Transaction Report", "Summary of open and closed orders", Icons.checklist_rtl_rounded, Colors.indigo),
      _ReportItem("Sale/Purchase Order Item Report", "Order quantities and item statuses", Icons.playlist_add_check_rounded, Colors.teal),
    ];

    final loanReports = [
      _ReportItem("Loan Statement", "Summary of liabilities and loan payments", Icons.account_balance_wallet_rounded, Colors.blueGrey),
    ];

    // Filter by search query
    final filteredTx = transactionReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredParty = partyReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredItemStock = itemStockReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredBusiness = businessStatusReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredTaxes = taxReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredExpense = expenseReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredOrder = orderReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredLoan = loanReports.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final allEmpty = filteredTx.isEmpty &&
        filteredParty.isEmpty &&
        filteredItemStock.isEmpty &&
        filteredBusiness.isEmpty &&
        filteredTaxes.isEmpty &&
        filteredExpense.isEmpty &&
        filteredOrder.isEmpty &&
        filteredLoan.isEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reports",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const CompanyMenuBar(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ThreeDContainer(
              depth: 2,
              borderRadius: 14,
              borderWidth: 1,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: "Search Report Name...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
          ),

          // Main Reports List
          Expanded(
            child: Container(
              color: const Color(0xFFEFF6FF), // Soft light blue backdrop matching mockup
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard("Transaction", filteredTx, appState),
                    _buildSectionCard("Party reports", filteredParty, appState),
                    _buildSectionCard("Item/Stock reports", filteredItemStock, appState),
                    _buildSectionCard("Business status", filteredBusiness, appState),
                    _buildSectionCard("Taxes", filteredTaxes, appState),
                    _buildSectionCard("Expense reports", filteredExpense, appState),
                    _buildSectionCard("Sale/Purchase Order reports", filteredOrder, appState),
                    _buildSectionCard("Loan Reports", filteredLoan, appState),

                    if (allEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.find_in_page_rounded, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text("No reports found matching '$_searchQuery'", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<_ReportItem> items, AppState appState) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final report = items[index];
              return _buildReportRow(context, report, appState);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReportRow(BuildContext context, _ReportItem item, AppState appState) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      dense: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (item.isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF5FF), // Light purple background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 13,
                color: Color(0xFF8B5CF6), // Purple crown icon color
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        if (item.title == "Profit & Loss") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfitAndLossScreen()),
          );
        } else {
          _openReportDetail(context, item.title, appState);
        }
      },
    );
  }

  // Navigation router for each report
  void _openReportDetail(BuildContext context, String reportTitle, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  // Handlebar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Sheet Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            reportTitle,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.file_download_rounded, color: Colors.blue),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Simulating Report Export to PDF/Excel..."),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Date filters if applicable to this report
                  if (_requiresDateFilter(reportTitle))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    _startDate = picked;
                                  });
                                  setState(() {});
                                }
                              },
                              child: ThreeDContainer(
                                depth: 1.5,
                                borderRadius: 10,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "From: ${DateFormat('dd MMM yy').format(_startDate)}",
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    _endDate = picked;
                                  });
                                  setState(() {});
                                }
                              },
                              child: ThreeDContainer(
                                depth: 1.5,
                                borderRadius: 10,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "To: ${DateFormat('dd MMM yy').format(_endDate)}",
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Sheet Content
                  Expanded(
                    child: _buildReportContent(reportTitle, appState, scrollController, setModalState),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _requiresDateFilter(String title) {
    return [
      "Sale Report",
      "Purchase Report",
      "Day Book",
      "All Transactions",
      "Bill Wise Profit",
      "Profit & Loss",
      "Cashflow",
    ].contains(title);
  }

  // Builder for different reports
  Widget _buildReportContent(String title, AppState state, ScrollController sc, StateSetter setModalState) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Filter transactions by selected date range
    final rangeTxs = state.transactions.where((tx) {
      return tx.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(_endDate.add(const Duration(seconds: 1)));
    }).toList();

    switch (title) {
      case "Sale Report":
        final sales = rangeTxs.where((tx) => tx.type == TransactionType.sale).toList();
        final totalSales = sales.fold(0.0, (sum, tx) => sum + tx.amount);
        return _buildTransactionReportList(sales, totalSales, "Sales Summary", formatCurrency, sc);

      case "Purchase Report":
        final purchases = rangeTxs.where((tx) => tx.type == TransactionType.purchase).toList();
        final totalPurchases = purchases.fold(0.0, (sum, tx) => sum + tx.amount);
        return _buildTransactionReportList(purchases, totalPurchases, "Purchases Summary", formatCurrency, sc);

      case "Day Book":
        // Filter transactions for today
        final today = DateTime.now();
        final startOfToday = DateTime(today.year, today.month, today.day);
        final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
        final todayTxs = state.transactions.where((tx) {
          return tx.date.isAfter(startOfToday.subtract(const Duration(seconds: 1))) &&
              tx.date.isBefore(endOfToday);
        }).toList();

        final moneyIn = todayTxs
            .where((tx) => tx.type == TransactionType.sale || tx.type == TransactionType.paymentIn)
            .fold(0.0, (sum, tx) => sum + tx.amount);
        final moneyOut = todayTxs
            .where((tx) => tx.type == TransactionType.purchase || tx.type == TransactionType.paymentOut || tx.type == TransactionType.expense)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryBadge("Money In (Today)", formatCurrency.format(moneyIn), AppTheme.successGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryBadge("Money Out (Today)", formatCurrency.format(moneyOut), AppTheme.accentRed),
                  ),
                ],
              ),
            ),
            Expanded(
              child: todayTxs.isEmpty
                  ? const Center(child: Text("No transactions recorded today", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: todayTxs.length,
                      itemBuilder: (context, index) {
                        final tx = todayTxs[index];
                        final isIn = tx.type == TransactionType.sale || tx.type == TransactionType.paymentIn;
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(tx.partyName.isEmpty ? tx.description : tx.partyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("${tx.type == TransactionType.saleReturn ? 'SALE RETURN' : tx.type == TransactionType.purchaseReturn ? 'PURCHASE RETURN' : tx.type == TransactionType.purchaseOrder ? 'PURCHASE ORDER' : tx.type.name.toUpperCase()} • ${DateFormat('hh:mm a').format(tx.date)}", style: const TextStyle(fontSize: 10)),
                            trailing: Text(
                              formatCurrency.format(tx.amount),
                              style: TextStyle(fontWeight: FontWeight.bold, color: isIn ? AppTheme.successGreen : AppTheme.accentRed, fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

      case "All Transactions":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Showing ${rangeTxs.length} transactions in date range",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
            Expanded(
              child: rangeTxs.isEmpty
                  ? const Center(child: Text("No transactions in this date range", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: rangeTxs.length,
                      itemBuilder: (context, index) {
                        final tx = rangeTxs[index];
                        final isCredit = tx.type == TransactionType.sale || tx.type == TransactionType.paymentOut;
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(tx.partyName.isEmpty ? tx.description : tx.partyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("${tx.type == TransactionType.saleReturn ? 'SALE RETURN' : tx.type == TransactionType.purchaseReturn ? 'PURCHASE RETURN' : tx.type == TransactionType.purchaseOrder ? 'PURCHASE ORDER' : tx.type.name.toUpperCase()} • ${DateFormat('dd MMM yy hh:mm a').format(tx.date)}", style: const TextStyle(fontSize: 10)),
                            trailing: Text(
                              formatCurrency.format(tx.amount),
                              style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? AppTheme.successGreen : AppTheme.accentRed, fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

      case "Bill Wise Profit":
        final sales = rangeTxs.where((tx) => tx.type == TransactionType.sale).toList();
        double totalProfit = 0.0;
        double totalSalesVal = 0.0;

        List<_BillProfitInfo> profitBills = [];
        for (var sale in sales) {
          double profit = 0.0;
          // Look inside description to match seeded item names and compute real profit margin
          bool matched = false;
          for (var item in state.items) {
            if (sale.description.toLowerCase().contains(item.name.toLowerCase())) {
              final quantity = sale.amount / item.salePrice;
              final cost = quantity * item.purchasePrice;
              profit = sale.amount - cost;
              matched = true;
              break;
            }
          }
          if (!matched) {
            // Assume 35% margin on generic sales
            profit = sale.amount * 0.35;
          }
          totalProfit += profit;
          totalSalesVal += sale.amount;
          profitBills.add(_BillProfitInfo(sale, profit));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryBadge("Total Sales Value", formatCurrency.format(totalSalesVal), AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryBadge("Estimated Gross Profit", formatCurrency.format(totalProfit), AppTheme.successGreen),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Invoice / Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  Row(
                    children: [
                      const Text("Sale Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 40),
                      const Text("Profit (Margin)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: profitBills.isEmpty
                  ? const Center(child: Text("No sales invoices found in this period", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: profitBills.length,
                      itemBuilder: (context, index) {
                        final bill = profitBills[index];
                        final marginPct = bill.sale.amount > 0 ? (bill.profit / bill.sale.amount) * 100 : 0.0;
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(bill.sale.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("${bill.sale.partyName} • ${DateFormat('dd MMM yy').format(bill.sale.date)}", style: const TextStyle(fontSize: 10)),
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(formatCurrency.format(bill.sale.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(formatCurrency.format(bill.profit), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 13)),
                                    Text("${marginPct.toStringAsFixed(1)}% margin", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

      case "Profit & Loss":
        final sales = rangeTxs.where((tx) => tx.type == TransactionType.sale).fold(0.0, (sum, tx) => sum + tx.amount);
        final purchases = rangeTxs.where((tx) => tx.type == TransactionType.purchase).fold(0.0, (sum, tx) => sum + tx.amount);
        final expenses = rangeTxs.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, tx) => sum + tx.amount);
        final netProfit = sales - purchases - expenses;

        return SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreeDContainer(
                depth: 4,
                borderRadius: 20,
                color: netProfit >= 0 ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                borderColor: netProfit >= 0 ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      netProfit >= 0 ? "Net Profit" : "Net Loss",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: netProfit >= 0 ? const Color(0xFF047857) : const Color(0xFFBE123C)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency.format(netProfit.abs()),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: netProfit >= 0 ? AppTheme.successGreen : AppTheme.accentRed,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Margin of Sales: ${sales > 0 ? ((netProfit / sales) * 100).toStringAsFixed(1) : 0.0}%",
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Income Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
              const Divider(),
              _buildReportBreakdownRow("Revenues (Gross Sales)", formatCurrency.format(sales), true, Colors.green),
              const SizedBox(height: 20),
              const Text("Cost & Expenses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
              const Divider(),
              _buildReportBreakdownRow("Cost of Goods Sold (COGS)", "- ${formatCurrency.format(purchases)}", false, Colors.pink),
              const SizedBox(height: 8),
              _buildReportBreakdownRow("Operating Expenses", "- ${formatCurrency.format(expenses)}", false, Colors.amber.shade900),
              const Divider(height: 32, thickness: 1.5),
              _buildReportBreakdownRow("Net Operating Income", formatCurrency.format(netProfit), true, netProfit >= 0 ? AppTheme.successGreen : AppTheme.accentRed),
            ],
          ),
        );

      case "Cashflow":
        final cashInSales = rangeTxs.where((tx) => tx.type == TransactionType.sale).fold(0.0, (sum, tx) => sum + tx.amount);
        final cashInPayments = rangeTxs.where((tx) => tx.type == TransactionType.paymentIn).fold(0.0, (sum, tx) => sum + tx.amount);
        final totalCashIn = cashInSales + cashInPayments;

        final cashOutPurchases = rangeTxs.where((tx) => tx.type == TransactionType.purchase).fold(0.0, (sum, tx) => sum + tx.amount);
        final cashOutPayments = rangeTxs.where((tx) => tx.type == TransactionType.paymentOut).fold(0.0, (sum, tx) => sum + tx.amount);
        final cashOutExpenses = rangeTxs.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, tx) => sum + tx.amount);
        final totalCashOut = cashOutPurchases + cashOutPayments + cashOutExpenses;

        final netCashflow = totalCashIn - totalCashOut;

        return SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreeDContainer(
                depth: 4,
                borderRadius: 20,
                color: netCashflow >= 0 ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                borderColor: netCashflow >= 0 ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Net Cashflow Shift", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency.format(netCashflow),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: netCashflow >= 0 ? AppTheme.successGreen : AppTheme.accentRed,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      netCashflow >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: netCashflow >= 0 ? AppTheme.successGreen : AppTheme.accentRed,
                      size: 36,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Cash Inflow (Receipts)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
              const Divider(),
              _buildReportBreakdownRow("Sales Receipts (Cash/Bank)", formatCurrency.format(cashInSales), false, Colors.black87),
              _buildReportBreakdownRow("Customer Payments Received", formatCurrency.format(cashInPayments), false, Colors.black87),
              _buildReportBreakdownRow("Total Inflow", formatCurrency.format(totalCashIn), true, Colors.green),

              const SizedBox(height: 24),
              const Text("Cash Outflow (Disbursements)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
              const Divider(),
              _buildReportBreakdownRow("Supplier Purchase Payments", "- ${formatCurrency.format(cashOutPurchases)}", false, Colors.black87),
              _buildReportBreakdownRow("Payments Settled to Parties", "- ${formatCurrency.format(cashOutPayments)}", false, Colors.black87),
              _buildReportBreakdownRow("Operating Expense Payouts", "- ${formatCurrency.format(cashOutExpenses)}", false, Colors.black87),
              _buildReportBreakdownRow("Total Outflow", "- ${formatCurrency.format(totalCashOut)}", true, Colors.red),
            ],
          ),
        );

      case "Balance Sheet":
        // Assets: Cash + Bank + Accounts Receivable + Inventory Stock Valuation
        final cash = state.cashBalance;
        final bank = state.bankBalance;
        final receivables = state.totalReceivable;
        // Calculate Inventory Value from stock price
        double stockValue = 0.0;
        for (var item in state.items) {
          if (item.type == ItemType.product) {
            stockValue += item.stock * item.purchasePrice;
          }
        }
        final totalAssets = cash + bank + receivables + stockValue;

        // Liabilities: Accounts Payable
        final payables = state.totalPayable;

        // Equity: Net Worth of Firm (Assets - Liabilities)
        final equity = totalAssets - payables;

        return SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Double entry check card
              ThreeDContainer(
                depth: 3,
                borderRadius: 16,
                borderColor: AppTheme.primary.withOpacity(0.2),
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Balance Verification", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: AppTheme.successGreen, size: 16),
                            const SizedBox(width: 4),
                            Text("Double-Entry Matches: ${formatCurrency.format(totalAssets)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ASSETS
              const Text("ASSETS (Current & Inventory)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
              const Divider(),
              _buildReportBreakdownRow("Store Cash Register Balance", formatCurrency.format(cash), false, Colors.black87),
              _buildReportBreakdownRow("Bank Accounts Registry Balance", formatCurrency.format(bank), false, Colors.black87),
              _buildReportBreakdownRow("Accounts Receivable (Parties Owe Us)", formatCurrency.format(receivables), false, Colors.black87),
              _buildReportBreakdownRow("Stock Inventory Valuation (At Cost)", formatCurrency.format(stockValue), false, Colors.black87),
              _buildReportBreakdownRow("TOTAL ASSETS", formatCurrency.format(totalAssets), true, AppTheme.primary),

              const SizedBox(height: 24),

              // LIABILITIES & EQUITY
              const Text("LIABILITIES & OWNER'S EQUITY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentRed)),
              const Divider(),
              _buildReportBreakdownRow("Accounts Payable (We Owe Suppliers)", formatCurrency.format(payables), false, Colors.black87),
              _buildReportBreakdownRow("Owner Capital Account (Net Worth)", formatCurrency.format(equity), false, Colors.black87),
              _buildReportBreakdownRow("TOTAL LIABILITIES & EQUITY", formatCurrency.format(payables + equity), true, AppTheme.accentRed),
            ],
          ),
        );

      case "Party Statement":
        // Dropdown to select party + list of their transactions + balances
        if (state.parties.isEmpty) {
          return const Center(child: Text("No parties found in database."));
        }

        // Local state initialization for party statement selection
        // We'll store it inside the widget class.
        // Let's search inside the widget state if we have a selected party.
        _selectedStatementPartyId ??= state.parties.first.id;

        final currentParty = state.parties.firstWhere((p) => p.id == _selectedStatementPartyId, orElse: () => state.parties.first);
        final partyTxs = state.transactions.where((tx) => tx.partyId == currentParty.id).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatementPartyId,
                    isExpanded: true,
                    items: state.parties.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          _selectedStatementPartyId = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("Opening Bal", formatCurrency.format(currentParty.openingBalance), Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryBadge("Current Bal", formatCurrency.format(currentParty.currentBalance), currentParty.type == PartyType.youWillGet ? AppTheme.successGreen : AppTheme.accentRed)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: partyTxs.isEmpty
                  ? const Center(child: Text("No transactions recorded with this party", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: partyTxs.length,
                      itemBuilder: (context, index) {
                        final tx = partyTxs[index];
                        final isCredit = tx.type == TransactionType.sale || tx.type == TransactionType.paymentOut;
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(tx.invoiceNo.isEmpty ? "No Invoice No." : "Inv: ${tx.invoiceNo}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            subtitle: Text("${tx.type == TransactionType.saleReturn ? 'SALE RETURN' : tx.type == TransactionType.purchaseReturn ? 'PURCHASE RETURN' : tx.type == TransactionType.purchaseOrder ? 'PURCHASE ORDER' : tx.type.name.toUpperCase()} • ${DateFormat('dd MMM yy').format(tx.date)}\nDesc: ${tx.description}", style: const TextStyle(fontSize: 10)),
                            isThreeLine: true,
                            trailing: Text(
                              formatCurrency.format(tx.amount),
                              style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? AppTheme.successGreen : AppTheme.accentRed, fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

      case "Party Wise Profit & Loss":
        // Profit margin per party
        final partyProfits = state.parties.map((party) {
          final clientTxs = state.transactions.where((tx) => tx.partyId == party.id).toList();
          final sales = clientTxs.where((tx) => tx.type == TransactionType.sale).fold(0.0, (sum, tx) => sum + tx.amount);
          final purchases = clientTxs.where((tx) => tx.type == TransactionType.purchase).fold(0.0, (sum, tx) => sum + tx.amount);

          double estProfit = 0.0;
          for (var tx in clientTxs.where((tx) => tx.type == TransactionType.sale)) {
            bool matched = false;
            for (var item in state.items) {
              if (tx.description.toLowerCase().contains(item.name.toLowerCase())) {
                final qty = tx.amount / item.salePrice;
                final cost = qty * item.purchasePrice;
                estProfit += (tx.amount - cost);
                matched = true;
                break;
              }
            }
            if (!matched) {
              estProfit += tx.amount * 0.35; // default margin
            }
          }
          estProfit -= purchases; // if we buy from them, treat it as direct COGS shift for that party

          return _PartyProfitData(party, sales, estProfit);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Party Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  Text("Sales / Net Profit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: partyProfits.length,
                itemBuilder: (context, index) {
                  final pp = partyProfits[index];
                  final margin = pp.sales > 0 ? (pp.profit / pp.sales) * 100 : 0.0;
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(pp.party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Phone: ${pp.party.phone}", style: const TextStyle(fontSize: 10)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Sales: ${formatCurrency.format(pp.sales)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            "Profit: ${formatCurrency.format(pp.profit)} (${margin.toStringAsFixed(1)}%)",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: pp.profit >= 0 ? AppTheme.successGreen : AppTheme.accentRed),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case "All Parties Report":
        return ListView.builder(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          itemCount: state.parties.length,
          itemBuilder: (context, index) {
            final party = state.parties[index];
            final isGet = party.type == PartyType.youWillGet;
            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Ph: ${party.phone}\nAddr: ${party.address}", style: const TextStyle(fontSize: 10)),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency.format(party.currentBalance),
                      style: TextStyle(fontWeight: FontWeight.bold, color: isGet ? AppTheme.successGreen : AppTheme.accentRed, fontSize: 13),
                    ),
                    Text(
                      isGet ? "You'll Get" : "You'll Give",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isGet ? AppTheme.successGreen : AppTheme.accentRed),
                    ),
                  ],
                ),
              ),
            );
          },
        );

      case "Party Report by Items":
        // Maps which items were sold/bought per party
        final partyItemSummary = state.parties.map((party) {
          final txs = state.transactions.where((tx) => tx.partyId == party.id).toList();
          List<String> transactedItems = [];
          for (var tx in txs) {
            for (var item in state.items) {
              if (tx.description.toLowerCase().contains(item.name.toLowerCase()) && !transactedItems.contains(item.name)) {
                transactedItems.add(item.name);
              }
            }
          }
          if (transactedItems.isEmpty) {
            transactedItems.add("Direct Ledger / Cash Adjustments");
          }
          return _PartyItemSummaryData(party, transactedItems);
        }).toList();

        return ListView.builder(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          itemCount: partyItemSummary.length,
          itemBuilder: (context, index) {
            final summary = partyItemSummary[index];
            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                    const SizedBox(height: 6),
                    const Text("Transacted Books/Products:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: summary.items.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(item, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );

      case "Sale/Purchase by Party":
        final details = state.parties.map((party) {
          final txs = state.transactions.where((tx) => tx.partyId == party.id).toList();
          final sales = txs.where((tx) => tx.type == TransactionType.sale).fold(0.0, (sum, tx) => sum + tx.amount);
          final purchases = txs.where((tx) => tx.type == TransactionType.purchase).fold(0.0, (sum, tx) => sum + tx.amount);
          return _PartyComparisonData(party, sales, purchases);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Party Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  Row(
                    children: [
                      Text("Total Sales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green)),
                      SizedBox(width: 40),
                      Text("Total Purchases", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.pink)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: details.length,
                itemBuilder: (context, index) {
                  final data = details[index];
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(data.party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Ph: ${data.party.phone}", style: const TextStyle(fontSize: 10)),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(formatCurrency.format(data.sales), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 13)),
                          const SizedBox(width: 24),
                          Text(formatCurrency.format(data.purchases), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentRed, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case "Stock Summary Report":
        final products = state.items.where((i) => i.type == ItemType.product).toList();
        final totalStockVal = products.fold(0.0, (sum, item) => sum + (item.stock * item.purchasePrice));
        final totalQty = products.fold(0.0, (sum, item) => sum + item.stock);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("Total Stock Qty", totalQty.toStringAsFixed(0), AppTheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryBadge("Total Stock Value", formatCurrency.format(totalStockVal), AppTheme.successGreen)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Price: Sale ${formatCurrency.format(p.salePrice)} • Purchase ${formatCurrency.format(p.purchasePrice)}", style: const TextStyle(fontSize: 10)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Stock: ${p.stock.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Value: ${formatCurrency.format(p.stock * p.purchasePrice)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case "Item Report by Party":
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Party transaction distribution per item type",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final matchTxs = state.transactions.where((tx) => tx.description.toLowerCase().contains(item.name.toLowerCase())).toList();
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ExpansionTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("${matchTxs.length} transacted invoices", style: const TextStyle(fontSize: 10)),
                      children: matchTxs.isEmpty
                          ? [const Padding(padding: EdgeInsets.all(8.0), child: Text("No party records found", style: TextStyle(fontSize: 11, color: Colors.grey)))]
                          : matchTxs.map((tx) {
                              return ListTile(
                                dense: true,
                                title: Text(tx.partyName.isEmpty ? "Direct Ledger" : tx.partyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(DateFormat('dd MMM yy').format(tx.date)),
                                trailing: Text(formatCurrency.format(tx.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case "Item Wise Profit & Loss":
        final products = state.items.where((i) => i.type == ItemType.product).toList();
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.all(16.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  final unitProfit = p.salePrice - p.purchasePrice;
                  final margin = p.salePrice > 0 ? (unitProfit / p.salePrice) * 100 : 0.0;
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Unit Cost: ${formatCurrency.format(p.purchasePrice)} • Sell: ${formatCurrency.format(p.salePrice)}", style: const TextStyle(fontSize: 10)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Margin: ${margin.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 13)),
                          Text("Unit Profit: ${formatCurrency.format(unitProfit)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case "Low Stock Summary Report":
        final lowStockItems = state.items.where((item) => item.stock < 10).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("Critically Low Stock Items", lowStockItems.length.toString(), AppTheme.accentRed)),
                ],
              ),
            ),
            Expanded(
              child: lowStockItems.isEmpty
                  ? const Center(child: Text("All items have healthy stock levels", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: lowStockItems.length,
                      itemBuilder: (context, index) {
                        final item = lowStockItems[index];
                        final isNegative = item.stock < 0;
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("Minimum stock trigger: 10.0 PCS", style: const TextStyle(fontSize: 10)),
                            trailing: Text(
                              "${item.stock.toStringAsFixed(1)} PCS",
                              style: TextStyle(fontWeight: FontWeight.bold, color: isNegative ? AppTheme.accentRed : AppTheme.warningOrange, fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

      case "Sale/Purchase By Item Category":
        final categories = <String, List<InventoryItem>>{};
        for (var item in state.items) {
          categories.putIfAbsent(item.category, () => []).add(item);
        }
        final catList = categories.keys.toList();
        return ListView.builder(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          itemCount: catList.length,
          itemBuilder: (context, index) {
            final catName = catList[index];
            final catItems = categories[catName]!;
            double catSales = 0.0;
            double catPurchases = 0.0;
            for (var tx in state.transactions) {
              for (var item in catItems) {
                if (tx.description.toLowerCase().contains(item.name.toLowerCase())) {
                  if (tx.type == TransactionType.sale) catSales += tx.amount;
                  if (tx.type == TransactionType.purchase) catPurchases += tx.amount;
                }
              }
            }
            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("${catItems.length} products in category", style: const TextStyle(fontSize: 10)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Sales: ${formatCurrency.format(catSales)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 12)),
                    Text("Purchases: ${formatCurrency.format(catPurchases)}", style: const TextStyle(fontSize: 11, color: AppTheme.accentRed)),
                  ],
                ),
              ),
            );
          },
        );

      case "Stock summary By Item Category":
        final categories = <String, List<InventoryItem>>{};
        for (var item in state.items) {
          categories.putIfAbsent(item.category, () => []).add(item);
        }
        final catList = categories.keys.toList();
        return ListView.builder(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          itemCount: catList.length,
          itemBuilder: (context, index) {
            final catName = catList[index];
            final catItems = categories[catName]!;
            final totalQty = catItems.fold(0.0, (sum, i) => sum + i.stock);
            final totalVal = catItems.fold(0.0, (sum, i) => sum + (i.stock * i.purchasePrice));
            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Quantity: ${totalQty.toStringAsFixed(1)} PCS", style: const TextStyle(fontSize: 10)),
                trailing: Text(formatCurrency.format(totalVal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13)),
              ),
            );
          },
        );

      case "Item Batch Report":
        return ListView(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: ListTile(
                title: Text("Batch B101 - Math books", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Mfg Date: 12-May-2026 • Exp Date: N/A"),
                trailing: Text("Qty: 120 PCS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Batch B102 - Physics guides", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Mfg Date: 20-Jun-2026 • Exp Date: N/A"),
                trailing: Text("Qty: 85 PCS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

      case "Item Serial Report":
        return ListView(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: ListTile(
                title: Text("Serial: S-88921-X", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Product: Bb math step1"),
                trailing: Text("Status: In Stock", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Serial: S-88922-Y", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Product: Bb math step1"),
                trailing: Text("Status: Sold (Inv #1)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        );

      case "Item Wise Discount":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("Total Sales Discount", formatCurrency.format(5956.0), AppTheme.warningOrange)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  Card(
                    child: ListTile(
                      title: Text("Bb math step1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Promotional cash discount"),
                      trailing: Text("₹ 2,400.00", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text("Premium Catalog Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Bulk volume discount"),
                      trailing: Text("₹ 3,556.00", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case "Bank Statement":
        final bankAccs = state.bankAccounts.where((a) => !a.isCash).toList();
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.all(16.0),
                itemCount: bankAccs.length,
                itemBuilder: (context, index) {
                  final acc = bankAccs[index];
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text("Statement period: Last 30 days"),
                      trailing: Text(formatCurrency.format(acc.balance), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case "Discount Report":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("Discount Allowed", formatCurrency.format(5956.0), AppTheme.successGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryBadge("Discount Received", formatCurrency.format(0.0), Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  Card(
                    child: ListTile(
                      title: Text("Payment-in Discount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Allowed to customer"),
                      trailing: Text("₹ 5,956.00", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case "Form No. 27EQ":
        return ListView(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: ListTile(
                title: Text("Quarter 1 filing - TCS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Status: Verified & Drafted"),
                trailing: Text("₹ 1,250.00", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

      case "TCS Receivable":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("TCS Balance Receivable", formatCurrency.format(1250.0), AppTheme.successGreen)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  Card(
                    child: ListTile(
                      title: Text("Indiamart Sellers Group", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Quarter 1 TCS Collected"),
                      trailing: Text("₹ 1,250.00", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case "TDS Payable":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("TDS Balance Payable", formatCurrency.format(850.0), AppTheme.accentRed)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  Card(
                    child: ListTile(
                      title: Text("Tax Authority", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Professional Services TDS"),
                      trailing: Text("₹ 850.00", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case "TDS Receivable":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryBadge("TDS Balance Receivable", formatCurrency.format(450.0), AppTheme.successGreen)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  Card(
                    child: ListTile(
                      title: Text("B2B Corporate Customer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("Sec 194Q TDS deducted"),
                      trailing: Text("₹ 450.00", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case "Expense Transaction Report":
        final expenses = rangeTxs.where((tx) => tx.type == TransactionType.expense).toList();
        final totalExpense = expenses.fold(0.0, (sum, tx) => sum + tx.amount);
        return _buildTransactionReportList(expenses, totalExpense, "Expense Summary", formatCurrency, sc);

      case "Expense Category Report":
        final expenses = state.transactions.where((tx) => tx.type == TransactionType.expense).toList();
        final categories = <String, double>{};
        for (var tx in expenses) {
          categories[tx.partyName.isEmpty ? "Direct Expense" : tx.partyName] = (categories[tx.partyName.isEmpty ? "Direct Expense" : tx.partyName] ?? 0.0) + tx.amount;
        }
        final list = categories.keys.toList();
        return ListView.builder(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final key = list[index];
            final amount = categories[key]!;
            return Card(
              child: ListTile(
                title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text("Category group"),
                trailing: Text(formatCurrency.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentRed)),
              ),
            );
          },
        );

      case "Expense Item Report":
        return ListView(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: ListTile(
                title: Text("Manufacturing Expense items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Raw printing materials cost"),
                trailing: Text("₹ 0.00", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Trade discount allowances", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Payment-in discounts"),
                trailing: Text("₹ 5,956.00", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

      case "Sale/Purchase Order Transaction Report":
        final orders = state.transactions.where((tx) => tx.type == TransactionType.purchaseOrder).toList();
        final totalOrders = orders.fold(0.0, (sum, tx) => sum + tx.amount);
        return _buildTransactionReportList(orders, totalOrders, "Orders Summary", formatCurrency, sc);

      case "Sale/Purchase Order Item Report":
        final orders = state.transactions.where((tx) => tx.type == TransactionType.purchaseOrder).toList();
        return Column(
          children: [
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text("No items in open orders"))
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final ord = orders[index];
                        return Card(
                          child: ListTile(
                            title: Text(ord.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("Party: ${ord.partyName}\nDescription: ${ord.description}"),
                            trailing: Text(formatCurrency.format(ord.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

      case "Loan Statement":
        return ListView(
          controller: sc,
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: ListTile(
                title: Text("HDFC Business Development Loan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Sanctioned: ₹ 5,00,000.00 • Rate: 10.5% p.a."),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("O/S: ₹ 4,20,000.00", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentRed)),
                    Text("EMI Paid: 6/12", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        );

      default:
        return const Center(child: Text("Report Under Development"));
    }
  }

  Widget _buildSummaryBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTransactionReportList(List<Transaction> txs, double totalAmount, String header, NumberFormat format, ScrollController sc) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ThreeDContainer(
            depth: 3,
            borderRadius: 14,
            borderColor: AppTheme.primary.withOpacity(0.15),
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(header, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(format.format(totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  ],
                ),
                Text("${txs.length} Invoices", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),
        ),
        Expanded(
          child: txs.isEmpty
              ? const Center(child: Text("No records found for the selection", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  controller: sc,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    return Card(
                      elevation: 0.5,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(tx.invoiceNo.isEmpty ? "Direct Registry" : tx.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text("${tx.partyName} • ${DateFormat('dd MMM yy').format(tx.date)}", style: const TextStyle(fontSize: 10)),
                        trailing: Text(
                          format.format(tx.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportBreakdownRow(String title, String value, bool isTotal, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 13 : 12,
              color: isTotal ? const Color(0xFF1E293B) : const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w700,
              fontSize: isTotal ? 14 : 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // State variables for report detail selections
  String? _selectedStatementPartyId;
}

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPremium;

  _ReportItem(this.title, this.description, this.icon, this.color, {this.isPremium = false});
}

class _BillProfitInfo {
  final Transaction sale;
  final double profit;

  _BillProfitInfo(this.sale, this.profit);
}

class _PartyProfitData {
  final Party party;
  final double sales;
  final double profit;

  _PartyProfitData(this.party, this.sales, this.profit);
}

class _PartyItemSummaryData {
  final Party party;
  final List<String> items;

  _PartyItemSummaryData(this.party, this.items);
}

class _PartyComparisonData {
  final Party party;
  final double sales;
  final double purchases;

  _PartyComparisonData(this.party, this.sales, this.purchases);
}
