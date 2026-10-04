import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class PremiumFeaturesScreen extends StatefulWidget {
  final int initialTab;
  const PremiumFeaturesScreen({super.key, this.initialTab = 0});

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Local state for Online Store Orders
  final List<_MockOrder> _mockOrders = [];

  // Local state for Staff
  final List<_StaffMember> _staff = [
    _StaffMember("Admin / Owner", "Owner", "Active"),
  ];

  // Text controllers for settings
  final _gstController = TextEditingController();
  final _upiController = TextEditingController();
  bool _isSyncing = false;

  // Track published state of items locally
  final Set<String> _publishedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gstController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text("Vypaar Premium", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.storefront_rounded), text: "Online Store"),
            Tab(icon: Icon(Icons.cloud_sync_rounded), text: "Cloud Sync"),
            Tab(icon: Icon(Icons.color_lens_rounded), text: "Invoice Customizer"),
            Tab(icon: Icon(Icons.card_giftcard_rounded), text: "Refer & Earn"),
            Tab(icon: Icon(Icons.people_alt_rounded), text: "Staff Access"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOnlineStoreTab(appState, theme),
          _buildCloudSyncTab(appState, theme),
          _buildInvoiceThemeTab(appState, theme),
          _buildReferralsTab(appState, theme),
          _buildStaffAccessTab(appState, theme),
        ],
      ),
    );
  }

  // --- 1. My Online Store Tab ---
  Widget _buildOnlineStoreTab(AppState state, ThemeData theme) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Store Status Header Banner
        ThreeDContainer(
          depth: 3,
          borderRadius: 20,
          borderColor: state.isOnlineStoreEnabled ? AppTheme.successGreen.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          color: state.isOnlineStoreEnabled ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 40,
                color: state.isOnlineStoreEnabled ? AppTheme.successGreen : Colors.grey,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Online Catalog",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      state.isOnlineStoreEnabled ? "Active at: myvypaar.in/surajbookstore" : "Offline / Disabled",
                      style: TextStyle(fontSize: 11, color: state.isOnlineStoreEnabled ? AppTheme.successGreen : Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.isOnlineStoreEnabled,
                activeColor: AppTheme.successGreen,
                onChanged: (val) {
                  state.toggleOnlineStore(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (state.isOnlineStoreEnabled) ...[
          // Configuration Panel
          const Text("Store Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          ThreeDContainer(
            depth: 2,
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Online Shop Name", border: OutlineInputBorder()),
                  onChanged: (val) => state.updateOnlineStoreName(val),
                  controller: TextEditingController(text: state.onlineStoreName)..selection = TextSelection.fromPosition(TextPosition(offset: state.onlineStoreName.length)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: "Order WhatsApp", border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => state.updateOnlineStoreWhatsApp(val),
                        controller: TextEditingController(text: state.onlineStoreWhatsApp)..selection = TextSelection.fromPosition(TextPosition(offset: state.onlineStoreWhatsApp.length)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: state.onlineStoreDeliveryFee.toStringAsFixed(0),
                        decoration: const InputDecoration(labelText: "Delivery Fee (₹)", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (val) {
                          final fee = double.tryParse(val) ?? 0.0;
                          state.updateOnlineStoreDeliveryFee(fee);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Orders Received subheader
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Online Orders Received", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("${_mockOrders.length} Orders", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._mockOrders.map((order) {
            Color statusColor = Colors.orange;
            if (order.status == "Dispatched") statusColor = Colors.blue;
            if (order.status == "Delivered") statusColor = AppTheme.successGreen;

            return Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text("${order.id} • ${order.partyName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Items: ${order.itemsDescription}\nTotal: ${formatCurrency.format(order.amount)}", style: const TextStyle(fontSize: 11)),
                isThreeLine: true,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.2))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: order.status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      items: const [
                        DropdownMenuItem(value: "Pending", child: Text("Pending")),
                        DropdownMenuItem(value: "Dispatched", child: Text("Dispatched")),
                        DropdownMenuItem(value: "Delivered", child: Text("Delivered")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            order.status = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),

          // Items Catalog publisher list
          const Text("Publish Catalog to Online Store", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.items.length,
            itemBuilder: (context, idx) {
              final item = state.items[idx];
              final isPublished = _publishedItems.contains(item.id);
              return Card(
                elevation: 0.5,
                margin: const EdgeInsets.only(bottom: 8),
                child: SwitchListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text("Price: ${formatCurrency.format(item.salePrice)} • SKU: ${item.code}", style: const TextStyle(fontSize: 10)),
                  value: isPublished,
                  activeColor: AppTheme.successGreen,
                  onChanged: (val) {
                    setState(() {
                      if (val) {
                        _publishedItems.add(item.id);
                      } else {
                        _publishedItems.remove(item.id);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Column(
                children: [
                  Icon(Icons.storefront_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text("Activate your Online Store to manage products\nand receive orders directly from customers.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --- 2. Cloud Sync Tab ---
  Widget _buildCloudSyncTab(AppState state, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Card showing Cloud Backup Status
        ThreeDContainer(
          depth: 3,
          borderRadius: 20,
          color: state.isCloudSyncEnabled ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
          borderColor: state.isCloudSyncEnabled ? AppTheme.successGreen.withOpacity(0.2) : AppTheme.accentRed.withOpacity(0.2),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    state.isCloudSyncEnabled ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    size: 44,
                    color: state.isCloudSyncEnabled ? AppTheme.successGreen : AppTheme.accentRed,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cloud Share & Sync Status",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          state.isCloudSyncEnabled ? "Automatic Backup: Enabled" : "Automatic Backup: Disabled",
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.isCloudSyncEnabled,
                    activeColor: AppTheme.successGreen,
                    onChanged: (val) {
                      state.toggleCloudSync(val);
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Connected Account", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const Text("jmdbookstoresiwan@gmail.com", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Last Backed Up", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text(
                        state.lastSyncTime != null
                            ? DateFormat('dd MMM yy, hh:mm a').format(state.lastSyncTime!)
                            : "Never",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Sync Trigger Button
        ThreeDButton(
          height: 48,
          color: AppTheme.primary,
          onPressed: _isSyncing
              ? null
              : () async {
                  setState(() => _isSyncing = true);
                  await state.triggerManualSync();
                  setState(() => _isSyncing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cloud sync completed. Data securely saved!"), backgroundColor: AppTheme.successGreen, behavior: SnackBarBehavior.floating),
                  );
                },
          child: _isSyncing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sync_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Sync Data Now", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
        ),
        const SizedBox(height: 24),

        // Cloud Log Console
        const Text("Sync Ledger Logs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: ListView.builder(
            itemCount: state.syncLogs.length,
            itemBuilder: (context, idx) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "[Sync Log] ${state.syncLogs[idx]}",
                  style: const TextStyle(color: Color(0xFF38BDF8), fontFamily: 'Courier', fontSize: 10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 3. Invoice Customizer Tab ---
  Widget _buildInvoiceThemeTab(AppState state, ThemeData theme) {
    final themes = [
      _InvoiceTheme("Modern Indigo", AppTheme.primary, Colors.indigo.shade50),
      _InvoiceTheme("Forest Emerald", AppTheme.successGreen, Colors.teal.shade50),
      _InvoiceTheme("Golden Premium", AppTheme.warningOrange, Colors.amber.shade50),
      _InvoiceTheme("Royal Blue", AppTheme.accentBlue, Colors.blue.shade50),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("Select Premium PDF Invoice Template", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 10),

        // Themes list horizontal
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final t = themes[index];
              final isSelected = state.invoiceTheme == t.name;
              return InkWell(
                onTap: () => state.updateInvoiceTheme(t.name),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: t.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? t.color : Colors.grey.shade300, width: isSelected ? 2.5 : 1),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.picture_as_pdf_rounded, color: t.color, size: 24),
                            const SizedBox(height: 6),
                            Text(t.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: t.color)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Icon(Icons.check_circle_rounded, color: t.color, size: 16),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        const Text("Invoice Configurator", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 8),

        ThreeDContainer(
          depth: 2,
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Show Business GSTIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                value: state.invoiceShowGST,
                onChanged: (val) => state.toggleInvoiceShowGST(val),
              ),
              if (state.invoiceShowGST)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: TextField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: "GSTIN Number", border: OutlineInputBorder()),
                  ),
                ),
              const Divider(height: 16),
              SwitchListTile(
                title: const Text("Include Payment QR Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                value: state.invoiceShowQR,
                onChanged: (val) => state.toggleInvoiceShowQR(val),
              ),
              if (state.invoiceShowQR)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: TextField(
                    controller: _upiController,
                    decoration: const InputDecoration(labelText: "UPI ID for QR Code", border: OutlineInputBorder()),
                  ),
                ),
              const Divider(height: 16),
              SwitchListTile(
                title: const Text("Add Authorized Signature Stamp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                value: state.invoiceShowSignature,
                onChanged: (val) => state.toggleInvoiceShowSignature(val),
              ),
              const Divider(height: 16),
              const ListTile(
                title: Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  maxLines: 2,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (val) => state.updateInvoiceTermsAndConditions(val),
                  controller: TextEditingController(text: state.invoiceTermsAndConditions)..selection = TextSelection.fromPosition(TextPosition(offset: state.invoiceTermsAndConditions.length)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 4. Refer & Earn Tab ---
  Widget _buildReferralsTab(AppState state, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Promo banner
        ThreeDContainer(
          depth: 4,
          borderRadius: 20,
          color: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFDE68A),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: AppTheme.warningOrange, size: 48),
              const SizedBox(height: 12),
              const Text("Get 1 Month Premium Free", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
              const SizedBox(height: 6),
              const Text(
                "Invite another business owner to Vypaar. When they record their first transaction, both of you get 1 Month Premium subscription added for free!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text("Your Shareable Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 8),

        ThreeDContainer(
          depth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Referral Code", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("VYP-SURAJ-992", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                ],
              ),
              ThreeDButton(
                width: 100,
                height: 38,
                borderRadius: 8,
                depth: 2,
                color: AppTheme.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Referral code copied to clipboard!"), behavior: SnackBarBehavior.floating),
                  );
                },
                text: "Copy",
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text("Invite Ledger Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 8),

        Card(
          child: ListTile(
            title: const Text("Sohan General Stores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text("Status: Active • Joined 10 Jul, 2026"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.successGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: const Text("Earned +1m", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text("Gupta Book House", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text("Status: Pending transaction"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: const Text("Pending", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
          ),
        ),
      ],
    );
  }

  // --- 5. Staff Access Tab ---
  Widget _buildStaffAccessTab(AppState state, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("Premium Staff Roles & Permissions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 10),

        // Roles breakdown description
        ThreeDContainer(
          depth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Available Roles:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary)),
              SizedBox(height: 6),
              Text("• Owner / Admin: Unlimited access to billing, stock, and reports.", style: TextStyle(fontSize: 11)),
              SizedBox(height: 4),
              Text("• Billing Staff: Create bills/invoices, edit transactions. Cannot view reports.", style: TextStyle(fontSize: 11)),
              SizedBox(height: 4),
              Text("• Delivery Boy: View dispatch sheets and status updates only.", style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Manage Staff operators", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
            ThreeDButton(
              width: 100,
              height: 34,
              borderRadius: 8,
              depth: 2,
              color: AppTheme.accentRed,
              onPressed: () {
                _showAddStaffDialog();
              },
              text: "+ Add",
            ),
          ],
        ),
        const SizedBox(height: 8),

        ..._staff.map((s) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text("Role: ${s.role} • Status: ${s.status}", style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _staff.remove(s);
                  });
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddStaffDialog() {
    final nameCtrl = TextEditingController();
    String selectedRole = "Billing Staff";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Invite Staff Operator"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Staff Name"),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "Admin", child: Text("Admin")),
                  DropdownMenuItem(value: "Billing Staff", child: Text("Billing Staff")),
                  DropdownMenuItem(value: "Delivery Boy", child: Text("Delivery Boy")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedRole = val;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _staff.add(_StaffMember(nameCtrl.text.trim(), selectedRole, "Pending Invite"));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Invite"),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockOrder {
  final String id;
  final String partyName;
  final double amount;
  final String itemsDescription;
  String status;

  _MockOrder(this.id, this.partyName, this.amount, this.itemsDescription, this.status);
}

class _StaffMember {
  final String name;
  final String role;
  final String status;

  _StaffMember(this.name, this.role, this.status);
}

class _InvoiceTheme {
  final String name;
  final Color color;
  final Color bgColor;

  _InvoiceTheme(this.name, this.color, this.bgColor);
}
