import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../widgets/company_menu_bar.dart';
import '../theme/app_theme.dart';
import 'add_party_dialog.dart';
import 'party_detail_screen.dart';
import 'payment_in_screen.dart';
import 'sale_screen.dart';
import '../widgets/transaction_types_modal.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; // 0 = Parties, 1 = Transactions, 2 = Items
  bool _isProductActive = true;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Business Header Screen
            _buildHeader(appState, theme),

            // 2. Custom 3D Sub-tabs (Parties vs Transactions vs Items)
            _buildSubTabs(theme),

            // 4. Main Content Area
            Expanded(
              child: _currentTab == 0
                  ? _buildPartyDetailsTab(appState, theme)
                  : _currentTab == 1
                      ? _buildTransactionDetailsTab(appState, theme)
                      : _buildItemsTab(appState, theme),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Add Sale Button
            Expanded(
              child: ThreeDButton(
                height: 48,
                borderRadius: 24,
                color: AppTheme.accentRed,
                icon: Icons.add_shopping_cart_rounded,
                text: "Add Sale",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SaleScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // 2. Take Payment Button
            Expanded(
              child: ThreeDButton(
                height: 48,
                borderRadius: 24,
                color: AppTheme.accentBlue,
                icon: Icons.price_change_rounded,
                text: "Take Payment",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentInScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // 3. Transactions (+) Modal Button
            ThreeDButton(
              width: 48,
              height: 48,
              borderRadius: 24,
              padding: EdgeInsets.zero,
              color: const Color(0xFF1E293B),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              onPressed: () {
                TransactionTypesModal.show(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Quick Action Bar for 3 requested features
  Widget _buildQuickActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          // 1. Add Sale Button
          Expanded(
            child: ThreeDButton(
              height: 42,
              borderRadius: 21,
              color: AppTheme.accentRed,
              icon: Icons.add_shopping_cart_rounded,
              text: "Add Sale",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SaleScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // 2. Take Payment Button
          Expanded(
            child: ThreeDButton(
              height: 42,
              borderRadius: 21,
              color: AppTheme.accentBlue,
              icon: Icons.price_change_rounded,
              text: "Take Payment",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentInScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // 3. All Transactions (+) Modal Button
          ThreeDButton(
            width: 44,
            height: 42,
            borderRadius: 21,
            padding: EdgeInsets.zero,
            color: const Color(0xFF1E293B),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {
              TransactionTypesModal.show(context);
            },
          ),
        ],
      ),
    );
  }

  // Header Builder
  Widget _buildHeader(AppState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Business Store Logo (3D Neumorphic representation) that triggers side Drawer
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: ThreeDContainer(
                depth: 3,
                borderRadius: 14,
                borderWidth: 1,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.menu_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Business Title
          Expanded(
            child: Text(
              state.businessName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppTheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Notification Action
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No new notifications"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded, size: 26, color: Color(0xFF64748B)),
          ),
          // Settings Action
          IconButton(
            onPressed: () {
              _showBusinessNameEditDialog(state, theme);
            },
            icon: const Icon(Icons.settings_outlined, size: 26, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // Edit Business name dialog
  void _showBusinessNameEditDialog(AppState state, ThemeData theme) {
    final controller = TextEditingController(text: state.businessName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Business Name", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Firm / Shop Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.updateBusinessName(controller.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Segmented sub-tabs mimicking original layout but 3D
  Widget _buildSubTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        children: [
          // Parties Tab (0)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 4.0),
              child: ThreeDButton(
                height: 46,
                borderRadius: 24,
                depth: _currentTab == 0 ? 4 : 2,
                color: _currentTab == 0 ? AppTheme.accentRed : Colors.white,
                textColor: _currentTab == 0 ? Colors.white : const Color(0xFF64748B),
                onPressed: () => setState(() {
                  _currentTab = 0;
                  _searchQuery = "";
                }),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Parties",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: _currentTab == 0 ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Transactions Tab (1)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ThreeDButton(
                height: 46,
                borderRadius: 24,
                depth: _currentTab == 1 ? 4 : 2,
                color: _currentTab == 1 ? AppTheme.accentBlue : Colors.white,
                textColor: _currentTab == 1 ? Colors.white : const Color(0xFF64748B),
                onPressed: () => setState(() {
                  _currentTab = 1;
                  _searchQuery = "";
                }),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Transactions",
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: _currentTab == 1 ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Items Tab (2)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(left: 4.0),
              child: ThreeDButton(
                height: 46,
                borderRadius: 24,
                depth: _currentTab == 2 ? 4 : 2,
                color: _currentTab == 2 ? AppTheme.primary : Colors.white,
                textColor: _currentTab == 2 ? Colors.white : const Color(0xFF64748B),
                onPressed: () => setState(() {
                  _currentTab = 2;
                  _searchQuery = "";
                }),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Items",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: _currentTab == 2 ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Party Details View
  Widget _buildPartyDetailsTab(AppState state, ThemeData theme) {
    // Filter parties based on search query
    final filteredParties = state.parties.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.phone.contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120.0),
      children: [
        // Upside Quick Add Party Action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ThreeDButton(
            height: 46,
            borderRadius: 23,
            color: AppTheme.accentRed,
            icon: Icons.person_add_alt_1_rounded,
            text: "Add New Party",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddPartyDialog(),
              );
            },
          ),
        ),
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
                hintText: "Search Party Name or Phone...",
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ),

        // Parties List
        if (filteredParties.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text("No parties found", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: filteredParties.map((party) => _buildPartyTile(party, theme)).toList(),
            ),
          ),
      ],
    );
  }

  // Parties Row Tile
  Widget _buildPartyTile(Party party, ThemeData theme) {
    final isGet = party.type == PartyType.youWillGet;
    final balanceColor = isGet ? AppTheme.successGreen : AppTheme.accentRed;
    final balanceText = isGet ? "You'll Get" : "You'll Give";
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ThreeDContainer(
        depth: 3,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartyDetailScreen(partyId: party.id),
            ),
          );
        },
        child: Row(
          children: [
            // 3D Avatar
            ThreeDContainer(
              depth: 2,
              borderRadius: 12,
              color: isGet ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
              borderColor: isGet ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.person_rounded,
                color: isGet ? AppTheme.successGreen : AppTheme.accentRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Party name & metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    party.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    party.phone.isNotEmpty ? "Ph: ${party.phone}" : "Party",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            // Balance figures
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency.format(party.currentBalance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: balanceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  balanceText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: balanceColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tab 2: Transaction Details View (General ledger view with quick shortcuts)
  Widget _buildTransactionDetailsTab(AppState state, ThemeData theme) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final recentTxs = state.transactions;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Total Receivable & Payable summary panels (Double 3D cards)
          Row(
            children: [
              // Receivable
              Expanded(
                child: ThreeDContainer(
                  depth: 4,
                  borderRadius: 18,
                  color: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFA7F3D0),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Receivable",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency.format(state.totalReceivable),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Payable
              Expanded(
                child: ThreeDContainer(
                  depth: 4,
                  borderRadius: 18,
                  color: const Color(0xFFFFF1F2),
                  borderColor: const Color(0xFFFECDD3),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Payable",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFBE123C)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency.format(state.totalPayable),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Speed actions for transaction creation
          _buildTransactionFastActions(),

          const SizedBox(height: 16),
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Transactions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
              ),
              Text(
                "${recentTxs.length} Total",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Transactions List
          Expanded(
            child: recentTxs.isEmpty
                ? Center(
                    child: Text("No transactions recorded yet", style: TextStyle(color: Colors.grey[600])),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: recentTxs.length,
                    itemBuilder: (context, index) {
                      final tx = recentTxs[index];
                      return _buildTransactionTile(tx, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Fast shortcut inputs for ledger actions
  Widget _buildTransactionFastActions() {
    return ThreeDContainer(
      depth: 4,
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildShortcutButton(
            icon: Icons.add_shopping_cart_rounded,
            label: "Add Sale",
            color: AppTheme.accentRed,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaleScreen()),
              );
            },
          ),
          _buildShortcutButton(
            icon: Icons.payment_rounded,
            label: "Take Payment",
            color: AppTheme.accentBlue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentInScreen()),
              );
            },
          ),
          _buildShortcutButton(
            icon: Icons.grid_view_rounded,
            label: "+ More Txns",
            color: const Color(0xFF1E293B),
            onPressed: () {
              TransactionTypesModal.show(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ThreeDButton(
      width: 100,
      height: 40,
      borderRadius: 12,
      depth: 3,
      color: Colors.white,
      textColor: color,
      borderColor: color.withOpacity(0.3),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Render Single Transaction Tile
  Widget _buildTransactionTile(Transaction tx, ThemeData theme) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final isCredit = tx.type == TransactionType.sale || tx.type == TransactionType.paymentOut;
    final color = isCredit ? AppTheme.successGreen : AppTheme.accentRed;
    final icon = tx.type == TransactionType.sale
        ? Icons.shopping_bag_outlined
        : tx.type == TransactionType.purchase
            ? Icons.shopping_cart_outlined
            : tx.type == TransactionType.expense
                ? Icons.receipt_long_rounded
                : tx.type == TransactionType.saleReturn
                    ? Icons.assignment_return_outlined
                    : Icons.payment_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ThreeDContainer(
        depth: 2,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.partyName.isEmpty ? "Direct cash transaction" : tx.partyName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${DateFormat('dd MMM, yy').format(tx.date)} • ${tx.invoiceNo}",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency.format(tx.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.type == TransactionType.saleReturn
                      ? "SALE RETURN"
                      : tx.type == TransactionType.purchaseReturn
                          ? "PURCHASE RETURN"
                          : tx.type == TransactionType.purchaseOrder
                              ? "PURCHASE ORDER"
                              : tx.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tab 3: Items/Books Catalog View
  Widget _buildItemsTab(AppState state, ThemeData theme) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Filter list based on type and search query
    final filteredItems = state.items.where((item) {
      final matchesType = _isProductActive
          ? item.type == ItemType.product
          : item.type == ItemType.service;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120.0),
      children: [
        // 1. Selector Segmented Tab (Books vs Rentals)
        _buildItemSelector(),

        // Upside Quick Add Book/Service Action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ThreeDButton(
            height: 46,
            borderRadius: 23,
            color: AppTheme.primary,
            icon: Icons.library_add_rounded,
            text: _isProductActive ? "Add Book" : "Add Service",
            onPressed: () => _showAddItemDialog(context, state),
          ),
        ),

        // 2. Search Bar
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
                hintText: "Search book title, author or ISBN...",
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ),

        // 3. Items List
        if (filteredItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_rounded, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  _isProductActive ? "No books listed in catalog" : "No services listed",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: filteredItems.map((item) => _buildItemTile(item, formatCurrency, theme)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildItemSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ThreeDButton(
              height: 44,
              borderRadius: 20,
              depth: _isProductActive ? 4 : 2,
              color: _isProductActive ? AppTheme.primary : Colors.white,
              textColor: _isProductActive ? Colors.white : const Color(0xFF64748B),
              onPressed: () => setState(() => _isProductActive = true),
              child: const Text("Books", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ThreeDButton(
              height: 44,
              borderRadius: 20,
              depth: _isProductActive ? 2 : 4,
              color: _isProductActive ? Colors.white : AppTheme.primary,
              textColor: _isProductActive ? const Color(0xFF64748B) : Colors.white,
              onPressed: () => setState(() => _isProductActive = false),
              child: const Text("Rentals / Services", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(InventoryItem item, NumberFormat format, ThemeData theme) {
    final isLowStock = item.stock < 15 && item.type == ItemType.product;
    final stockBadgeColor = isLowStock ? AppTheme.warningOrange : AppTheme.successGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ThreeDContainer(
        depth: 3,
        borderRadius: 16,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // 3D book icon thumbnail
            ThreeDContainer(
              depth: 2,
              borderRadius: 12,
              color: item.type == ItemType.product ? const Color(0xFFFAF1EB) : const Color(0xFFF5F3FF),
              borderColor: item.type == ItemType.product ? const Color(0xFFFCD34D) : const Color(0xFFDDD6FE),
              padding: const EdgeInsets.all(10),
              child: Icon(
                item.type == ItemType.product ? Icons.menu_book_rounded : Icons.bookmark_rounded,
                color: item.type == ItemType.product ? AppTheme.warningOrange : Colors.purple,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Price: ${format.format(item.salePrice)}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      if (item.type == ItemType.product) ...[
                        const SizedBox(width: 8),
                        Text(
                          "• Cost: ${format.format(item.purchasePrice)}",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Stock Column
            if (item.type == ItemType.product)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockBadgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: stockBadgeColor.withOpacity(0.2), width: 1),
                    ),
                    child: Text(
                      "${item.stock.toInt()} ${item.unit}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: stockBadgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLowStock ? "Low Stock" : "In Stock",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isLowStock ? AppTheme.warningOrange : Colors.grey[500],
                    ),
                  ),
                ],
              )
            else
              Text(
                "RENTAL / SERVICE",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, AppState state) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final saleController = TextEditingController();
    final purchaseController = TextEditingController();
    final stockController = TextEditingController();
    final unitController = TextEditingController(text: "PCS");
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          _isProductActive ? "Add New Book" : "Add Rental / Service",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(nameController, "Book Title / Name", Icons.book_rounded, (v) {
                  if (v == null || v.trim().isEmpty) return "Title is required";
                  return null;
                }),
                const SizedBox(height: 10),
                _buildDialogField(saleController, "Sale Price (₹)", Icons.sell_outlined, (v) {
                  if (v == null || v.isEmpty) return "Price required";
                  if (double.tryParse(v) == null) return "Invalid price";
                  return null;
                }, keyboardType: TextInputType.number),
                if (_isProductActive) ...[
                  const SizedBox(height: 10),
                  _buildDialogField(purchaseController, "Cost Price (₹)", Icons.shopping_cart_outlined, (v) {
                    if (v == null || v.isEmpty) return "Price required";
                    if (double.tryParse(v) == null) return "Invalid price";
                    return null;
                  }, keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogField(stockController, "Init Stock", Icons.warehouse_outlined, (v) {
                          if (v == null || v.isEmpty) return "Stock required";
                          if (double.tryParse(v) == null) return "Invalid stock";
                          return null;
                        }, keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDialogField(unitController, "Unit", Icons.ac_unit, (v) {
                          if (v == null || v.isEmpty) return "Unit required";
                          return null;
                        }),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                _buildDialogField(codeController, "ISBN / Book Code", Icons.qr_code_outlined, null),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newItem = InventoryItem(
                  id: "i_${DateTime.now().millisecondsSinceEpoch}",
                  name: nameController.text.trim(),
                  type: _isProductActive ? ItemType.product : ItemType.service,
                  stock: _isProductActive ? (double.tryParse(stockController.text.trim()) ?? 0.0) : 0.0,
                  salePrice: double.parse(saleController.text.trim()),
                  purchasePrice: _isProductActive ? double.parse(purchaseController.text.trim()) : 0.0,
                  unit: _isProductActive ? unitController.text.trim().toUpperCase() : "SRV",
                  code: codeController.text.trim().isNotEmpty
                      ? codeController.text.trim()
                      : "ISBN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
                );

                state.addInventoryItem(newItem);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("'${newItem.name}' added to catalog!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Save Book"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
