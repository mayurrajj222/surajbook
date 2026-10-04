import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ProfitAndLossScreen extends StatefulWidget {
  const ProfitAndLossScreen({super.key});

  @override
  State<ProfitAndLossScreen> createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> {
  DateTime _startDate = DateTime(2026, 7, 1);
  DateTime _endDate = DateTime(2026, 7, 31);
  String _dateIntervalLabel = "This Month";

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // 1. Filter Transactions within date range
    final rangeTxs = appState.transactions.where((tx) {
      return tx.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(_endDate.add(const Duration(seconds: 1)));
    }).toList();

    // 2. Aggregate dynamic figures
    final double sales = rangeTxs
        .where((tx) => tx.type == TransactionType.sale)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    final double saleReturns = rangeTxs
        .where((tx) => tx.type == TransactionType.saleReturn)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    final double purchases = rangeTxs
        .where((tx) => tx.type == TransactionType.purchase)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    final double purchaseReturns = rangeTxs
        .where((tx) => tx.type == TransactionType.purchaseReturn)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    final double expenses = rangeTxs
        .where((tx) => tx.type == TransactionType.expense)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    // Hardcoded FA variables for matching mockup placeholders
    const double saleFA = 0.0;
    const double purchaseFA = 0.0;
    const double discount = 0.0;
    const double openingStock = 0.0;
    const double closingStock = 0.0;
    const double openingFAStock = 0.0;
    const double closingFAStock = 0.0;
    const double indirectExpenses = 0.0;

    // 3. Compute Profit / Loss
    final double grossProfit = sales + saleFA - saleReturns - purchases - purchaseFA + purchaseReturns + discount - openingStock + closingStock - openingFAStock + closingFAStock;
    final double netProfit = grossProfit - expenses - indirectExpenses;

    // Individual category expenses aggregations
    final List<String> categories = ["Manufacturing Expense", "Petrol", "Rent", "Salary", "Tea", "Transport"];
    double getCategoryExpense(String cat) {
      return rangeTxs
          .where((tx) => tx.type == TransactionType.expense && tx.description.toLowerCase().contains(cat.toLowerCase()))
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profit And Loss Report",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Red PDF Icon Action
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Pdf",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Exporting Profit & Loss PDF...")),
              );
            },
          ),
          // Green XLS Icon Action
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "xls",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Exporting Profit & Loss Excel Sheet...")),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Date Interval Selectors Directly Below AppBar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Interval Dropdown
                InkWell(
                  onTap: () => _selectInterval(),
                  child: Row(
                    children: [
                      Text(
                        _dateIntervalLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
                // Vertical divider line
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                ),
                // Calendar trigger & display
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCustomDateRange(),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "${DateFormat('dd/MM/yyyy').format(_startDate)} TO ${DateFormat('dd/MM/yyyy').format(_endDate)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Gross Profit & Net Profit Cards (On a blue backdrop)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFFEFF6FF), // Soft light blue background
            child: Row(
              children: [
                // Gross Profit
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gross Profit",
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency.format(grossProfit),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: grossProfit >= 0 ? const Color(0xFF16A34A) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Net Profit
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Net Profit",
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency.format(netProfit),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: netProfit >= 0 ? const Color(0xFF16A34A) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Particulars Ledger Table
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: const Color(0xFFF8FAFC),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Particulars", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                          Text("Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Group 1: General Business Activities
                    _buildParticularsRow("Sale (+)", sales, isPositive: true),
                    _buildParticularsRow("Sale FA (+)", saleFA, isPositive: true),
                    _buildParticularsRow("Cr. Note/Sale Return (-)", saleReturns, isPositive: false),
                    _buildParticularsRow("Purchase (-)", purchases, isPositive: false),
                    _buildParticularsRow("Purchase FA (-)", purchaseFA, isPositive: false),
                    _buildParticularsRow("Dr. Note/Purchase Return (+)", purchaseReturns, isPositive: true),
                    _buildParticularsRow("Payment Out Discount (+)", discount, isPositive: true),

                    // Group 2: Stocks Header
                    _buildGroupHeader("Stocks"),
                    _buildParticularsRow("Opening Stock (-)", openingStock, isPositive: false),
                    _buildParticularsRow("Closing Stock (+)", closingStock, isPositive: true),
                    _buildParticularsRow("Opening FA Stock (-)", openingFAStock, isPositive: false),
                    _buildParticularsRow("Closing FA Stock (+)", closingFAStock, isPositive: true),

                    // Group 3: Expenses Header
                    _buildGroupHeader("Direct Expenses (-)"),
                    ...categories.map((cat) {
                      final amt = getCategoryExpense(cat);
                      return _buildParticularsRow(cat, amt, isPositive: false);
                    }),
                    _buildParticularsRow("Indirect Expenses (-)", indirectExpenses, isPositive: false),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticularsRow(String particular, double val, {required bool isPositive}) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final amountColor = isPositive
        ? const Color(0xFF16A34A) // Green
        : val > 0
            ? const Color(0xFFEF4444) // Red only if non-zero
            : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            particular,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
          ),
          Text(
            formatCurrency.format(val),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String groupName) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        groupName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  void _selectInterval() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Today"),
              onTap: () {
                setState(() {
                  _startDate = DateTime.now();
                  _endDate = DateTime.now();
                  _dateIntervalLabel = "Today";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("This Week"),
              onTap: () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 7));
                  _endDate = DateTime.now();
                  _dateIntervalLabel = "This Week";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("This Month"),
              onTap: () {
                setState(() {
                  _startDate = DateTime(2026, 7, 1);
                  _endDate = DateTime(2026, 7, 31);
                  _dateIntervalLabel = "This Month";
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _dateIntervalLabel = "Custom";
      });
    }
  }
}
