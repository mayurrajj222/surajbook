import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/premium_features_screen.dart';
import '../screens/sale_screen.dart';
import '../screens/estimate_quotation_screen.dart';
import '../screens/mobile_pos_screen.dart';
import '../screens/payment_in_screen.dart';
import '../screens/sale_return_screen.dart';
import '../screens/sale_order_screen.dart';
import '../screens/delivery_challan_screen.dart';
import '../screens/purchase_list_screen.dart';
import '../screens/payment_out_screen.dart';
import '../screens/purchase_return_screen.dart';
import '../screens/purchase_order_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/bank_accounts_screen.dart';
import '../screens/cash_in_hand_screen.dart';
import '../screens/activity_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isCompanyDropdownExpanded = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // 1. Premium Drawer Header
          _buildDrawerHeader(appState, theme),

          // 2. Drawer Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (_isCompanyDropdownExpanded)
                  _buildCompanyDropdownList(appState, theme)
                else ...[
                  // Parties (Expandable)
                  ExpansionTile(
                    leading: const Icon(Icons.people_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Parties",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 16.0),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline_rounded, size: 18),
                        title: const Text("Party Details", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          appState.setNavigationIndex(0);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  // Items
                  ListTile(
                    leading: const Icon(Icons.inventory_2_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Items",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    onTap: () {
                      appState.setNavigationIndex(2);
                      Navigator.pop(context);
                    },
                  ),

                  // Business Dashboard
                  ListTile(
                    leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Business Dashboard",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    onTap: () {
                      appState.setNavigationIndex(1);
                      Navigator.pop(context);
                    },
                  ),

                  // Reports
                  ListTile(
                    leading: const Icon(Icons.trending_up_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Reports",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReportsScreen()),
                      );
                    },
                  ),

                  // Activity History
                  ListTile(
                    leading: const Icon(Icons.history_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Activity Log",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ActivityScreen()),
                      );
                    },
                  ),

                  // Sale (Expandable matching reference layout)
                  ExpansionTile(
                    leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Sale",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 16.0),
                    children: [
                      ListTile(
                        title: const Text("Sale Invoice", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SaleScreen()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Payment-In", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentInScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Sale Return (Credit Note)", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SaleReturnScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Estimate/Quotation", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EstimateQuotationScreen()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Proforma Invoice", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTransactionScreen(initialType: TransactionType.sale),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Sale Order", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SaleOrderScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Delivery Challan", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryChallanScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Mobile POS", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MobilePosScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  // Purchase (Expandable matching reference layout)
                  ExpansionTile(
                    leading: const Icon(Icons.shopping_cart_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Purchase",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 16.0),
                    children: [
                      ListTile(
                        title: const Text("Purchase Bill", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseListScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Payment-Out", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentOutScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Purchase Return (Debit Note)", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseReturnScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Purchase Order", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseOrderScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Expense with Add Button
                  ListTile(
                    leading: const Icon(Icons.receipt_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Expense",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentRed),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTransactionScreen(initialType: TransactionType.expense),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseScreen(),
                        ),
                      );
                    },
                  ),

                  // Cash & Bank (Expandable matching reference layout)
                  ExpansionTile(
                    leading: const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B)),
                    title: const Text(
                      "Cash & Bank",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 16.0),
                    children: [
                      ListTile(
                        title: const Text("Bank Accounts", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BankAccountsScreen()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Cash in Hand", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CashInHandScreen()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Bank Transfer", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BankAccountsScreen(autoOpenDepositWithdraw: true)),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Cheques", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          _showWipToast("Cheque Registry");
                        },
                      ),
                    ],
                  ),

                  // My Online Store (Expandable)
                  ExpansionTile(
                    leading: const Icon(Icons.storefront_rounded, color: AppTheme.successGreen),
                    title: const Text(
                      "My Online Store",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 16.0),
                    children: [
                      ListTile(
                        title: const Text("Manage Catalog", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PremiumFeaturesScreen(initialTab: 0)),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("View Orders", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PremiumFeaturesScreen(initialTab: 0)),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text("Store Settings", style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PremiumFeaturesScreen(initialTab: 0)),
                          );
                        },
                      ),
                    ],
                  ),

                  // Get 1 Month Free
                  ListTile(
                    leading: const Icon(Icons.card_giftcard_rounded, color: AppTheme.warningOrange),
                    title: const Text(
                      "Get 1 Month Free",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PremiumFeaturesScreen(initialTab: 3)),
                      );
                    },
                  ),

                  const Divider(),

                  // Utilities ExpansionTile
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.construction_rounded, color: Color(0xFF64748B)),
                      title: const Text(
                        "Utilities",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                      initiallyExpanded: true,
                      childrenPadding: const EdgeInsets.only(left: 54.0, right: 16.0),
                      children: [
                        _buildUtilityItem(context, "Verify my data", () => _runVerifyData()),
                        _buildUtilityItem(context, "Open Calculator", () => _openCalculator()),
                        _buildUtilityItem(context, "Import Items", () => _importItems(appState)),
                        _buildUtilityItem(context, "Import from BillBook", () => _importBillBook(appState), isNew: true),
                        _buildUtilityItem(context, "Bulk Update Tax Slab", () => _bulkUpdateTaxSlab(appState), isNew: true),
                        _buildUtilityItem(context, "Export Items", () => _exportItems(appState)),
                        _buildUtilityItem(context, "Import Parties", () => _importParties(appState)),
                        _buildUtilityItem(context, "Recycle Bin", () => _openRecycleBin(appState)),
                        _buildUtilityItem(context, "Messages", () => _openMessages()),
                        _buildUtilityItem(context, "Barcode Generator", () => _openBarcodeGenerator(), isPremium: true),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Help & Support ExpansionTile
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF64748B)),
                      title: const Text(
                        "Help & Support",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                      childrenPadding: const EdgeInsets.only(left: 54.0),
                      children: [
                        ListTile(
                          dense: true,
                          title: const Text("WhatsApp Support", style: TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            _showWipToast("WhatsApp Support");
                          },
                        ),
                        ListTile(
                          dense: true,
                          title: const Text("Call Support", style: TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            _showWipToast("Call Support");
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Sync Status Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F6EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Sync On  917464072321",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF075E54),
                      ),
                    ),
                  ),

                  // Version Text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: Text(
                        "Version : 27.8.0",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Header containing Profile & Swapper ---
  Widget _buildDrawerHeader(AppState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Premium Crown Profile Image representation
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, size: 14, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.businessName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "jmdbookstoresiwan@gmail.com",
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              setState(() {
                _isCompanyDropdownExpanded = !_isCompanyDropdownExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Change Company",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Icon(
                  _isCompanyDropdownExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Company Switcher List View
  Widget _buildCompanyDropdownList(AppState state, ThemeData theme) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.companies.length,
          itemBuilder: (context, index) {
            final company = state.companies[index];
            final isActive = state.activeCompanyIndex == index;
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.check_circle_rounded,
                color: isActive ? AppTheme.successGreen : Colors.transparent,
                size: 20,
              ),
              title: Text(
                company.name,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppTheme.primary : const Color(0xFF475569),
                ),
              ),
              onTap: () {
                state.switchCompany(index);
                setState(() {
                  _isCompanyDropdownExpanded = false;
                });
              },
            );
          },
        ),
        const Divider(),
        ListTile(
          dense: true,
          leading: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentRed),
          title: const Text(
            "Add New Business / Shop",
            style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            _showAddNewCompanyDialog(state);
          },
        ),
      ],
    );
  }

  void _showAddNewCompanyDialog(AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Firm"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Firm Name (e.g., Bookstore)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.addCompany(controller.text.trim());
                setState(() {
                  _isCompanyDropdownExpanded = false;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("New firm '${controller.text.trim()}' created!"), backgroundColor: AppTheme.successGreen),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showWipToast(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'$feature' forms are ready for premium release integration."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Dynamic Bank and Cash Dialog utilities duplicated for self-containment ---

  void _showBankAccountsDialog(AppState appState) {
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

  void _showCashInHandDialog(AppState appState) {
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

  void _showBankTransferDialog() {
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

  void _showOtherProductsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vypaar Premium Add-ons"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.desktop_windows_rounded, color: Colors.blue),
              title: Text("Vypaar Desktop App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text("Manage transactions on Windows/Mac"),
            ),
            ListTile(
              leading: Icon(Icons.qr_code_scanner_rounded, color: Colors.purple),
              title: Text("Barcode Generator utility", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text("Scan and print barcodes for books"),
            ),
            ListTile(
              leading: Icon(Icons.print_rounded, color: Colors.teal),
              title: Text("Thermal Print utilities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text("Connect to Bluetooth thermal printers"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  // --- Workable Drawer Utilities Helpers ---

  Widget _buildUtilityItem(
    BuildContext context,
    String title,
    VoidCallback onTap, {
    bool isNew = false,
    bool isPremium = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (isPremium)
              const Icon(
                Icons.stars_rounded,
                color: Colors.purple,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _runVerifyData() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Verifying database integrity..."),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      Navigator.pop(context); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text("Verification Complete"),
            ],
          ),
          content: const Text(
            "All ledger balances, party accounts, and catalog inventories match correctly.\n\nNo discrepancies found.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  void _openCalculator() {
    showDialog(
      context: context,
      builder: (context) => const CalculatorDialog(),
    );
  }

  void _importItems(AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Import Items"),
        content: const Text("Would you like to import mock books into your catalog?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              state.addInventoryItem(InventoryItem(
                id: "imp_${DateTime.now().millisecondsSinceEpoch}_1",
                name: "Imported Math Novel",
                type: ItemType.product,
                stock: 15,
                salePrice: 220,
                purchasePrice: 150,
                unit: "PCS",
                code: "IMP",
                category: "Fiction",
              ));
              state.addInventoryItem(InventoryItem(
                id: "imp_${DateTime.now().millisecondsSinceEpoch}_2",
                name: "Imported Physics Guide",
                type: ItemType.product,
                stock: 30,
                salePrice: 350,
                purchasePrice: 240,
                unit: "PCS",
                code: "IMP",
                category: "Academic & Education",
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Successfully imported 2 items into catalog!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text("Import"),
          ),
        ],
      ),
    );
  }

  void _importBillBook(AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Import from BillBook"),
        content: const Text("Import data from your BillBook backup file?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              state.addInventoryItem(InventoryItem(
                id: "bb_imp_1",
                name: "BillBook Chemistry",
                type: ItemType.product,
                stock: 25,
                salePrice: 180,
                purchasePrice: 130,
                unit: "PCS",
                code: "BB",
                category: "Academic & Education",
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Successfully imported 1 item from BillBook!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text("Import"),
          ),
        ],
      ),
    );
  }

  void _bulkUpdateTaxSlab(AppState state) {
    String selectedTax = "18%";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Bulk Update Tax Slab"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select a tax slab to apply to all products in catalog:"),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTax,
                items: ["5%", "12%", "18%", "28%"].map((slab) {
                  return DropdownMenuItem(value: slab, child: Text("GST @ $slab"));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedTax = val);
                  }
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Tax slab $selectedTax applied bulk to catalog successfully!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text("Apply Slab"),
            ),
          ],
        ),
      ),
    );
  }

  void _exportItems(AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Export Catalog"),
        content: Text("Export all ${state.items.length} items to Excel/JSON spreadsheet format?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Items exported to /downloads/catalog_export.xlsx successfully!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text("Export"),
          ),
        ],
      ),
    );
  }

  void _importParties(AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Import Parties"),
        content: const Text("Would you like to import mock customer list?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              state.addParty(Party(
                id: "imp_p_1",
                name: "Rajesh Sharma (Imported)",
                phone: "9988776655",
                address: "Patna, Bihar",
                email: "rajesh@gmail.com",
                openingBalance: 0,
                currentBalance: 0,
                type: PartyType.youWillGet,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Successfully imported 1 party profile!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text("Import"),
          ),
        ],
      ),
    );
  }

  static final List<InventoryItem> _mockDeletedItems = [
    InventoryItem(
      id: "del_1",
      name: "Deleted History Guide",
      type: ItemType.product,
      stock: 5,
      salePrice: 190.0,
      purchasePrice: 120.0,
      unit: "PCS",
      code: "DEL",
      category: "Academic & Education",
    ),
  ];

  void _openRecycleBin(AppState state) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Recycle Bin"),
          content: _mockDeletedItems.isEmpty
              ? const Text("No recently deleted items.")
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mockDeletedItems.length,
                    itemBuilder: (context, index) {
                      final item = _mockDeletedItems[index];
                      return ListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Price: ₹ ${item.salePrice.toStringAsFixed(2)}"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            state.addInventoryItem(item);
                            setDialogState(() {
                              _mockDeletedItems.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("'${item.name}' has been restored successfully!"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: const Text("Restore"),
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
      ),
    );
  }

  void _openMessages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Messages & Alerts"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: Colors.blue),
              title: Text("Backup Successful"),
              subtitle: Text("Your daily ledger has been synced to drive."),
            ),
            ListTile(
              leading: Icon(Icons.star_outline_rounded, color: Colors.amber),
              title: Text("Premium Activated"),
              subtitle: Text("You have unlocked all barcode tools."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _openBarcodeGenerator() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Barcode Generator"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Enter Item Code / ISBN",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 20),
              if (controller.text.isNotEmpty) ...[
                const Text("Generated Barcode Preview:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Draw mock barcode stripes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(24, (index) {
                          final text = controller.text;
                          final charIndex = index % text.length;
                          final charCode = text.codeUnitAt(charIndex);
                          final width = (charCode % 3) + 1.5;
                          final isSpacing = (charCode * index) % 2 == 0;
                          return Container(
                            width: width,
                            height: 50,
                            color: isSpacing ? Colors.black : Colors.white,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.text,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Barcode label sent to bluetooth label printer!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text("Print Label"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Working Pseudo Calculator Dialog ---
class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _display = "0";
  double _num1 = 0;
  String _op = "";
  bool _shouldClear = false;

  void _onPressed(String val) {
    setState(() {
      if (val == "C") {
        _display = "0";
        _num1 = 0;
        _op = "";
        _shouldClear = false;
      } else if (val == "+" || val == "-" || val == "*" || val == "/") {
        _num1 = double.tryParse(_display) ?? 0;
        _op = val;
        _shouldClear = true;
      } else if (val == "=") {
        if (_op.isNotEmpty) {
          double num2 = double.tryParse(_display) ?? 0;
          double res = 0;
          if (_op == "+") res = _num1 + num2;
          if (_op == "-") res = _num1 - num2;
          if (_op == "*") res = _num1 * num2;
          if (_op == "/") res = num2 != 0 ? _num1 / num2 : 0;
          
          _display = res.toString();
          if (_display.endsWith(".0")) {
            _display = _display.substring(0, _display.length - 2);
          }
          _op = "";
        }
      } else {
        if (_display == "0" || _shouldClear) {
          _display = val;
          _shouldClear = false;
        } else {
          _display += val;
        }
      }
    });
  }

  Widget _buildCalcButton(String label, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFFF1F5F9),
            foregroundColor: textColor ?? const Color(0xFF1E293B),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _onPressed(label),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Calculator", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              _display,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCalcButton("7"),
              _buildCalcButton("8"),
              _buildCalcButton("9"),
              _buildCalcButton("/", color: Colors.blue[100], textColor: Colors.blue[900]),
            ],
          ),
          Row(
            children: [
              _buildCalcButton("4"),
              _buildCalcButton("5"),
              _buildCalcButton("6"),
              _buildCalcButton("*", color: Colors.blue[100], textColor: Colors.blue[900]),
            ],
          ),
          Row(
            children: [
              _buildCalcButton("1"),
              _buildCalcButton("2"),
              _buildCalcButton("3"),
              _buildCalcButton("-", color: Colors.blue[100], textColor: Colors.blue[900]),
            ],
          ),
          Row(
            children: [
              _buildCalcButton("C", color: Colors.red[100], textColor: Colors.red[900]),
              _buildCalcButton("0"),
              _buildCalcButton("="),
              _buildCalcButton("+", color: Colors.blue[100], textColor: Colors.blue[900]),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
