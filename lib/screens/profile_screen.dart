import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("Store Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Store Header Info Card (Claymorphic)
            ThreeDContainer(
              depth: 5,
              borderRadius: 24,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Book store badge logo
                  ThreeDContainer(
                    depth: 2,
                    borderRadius: 20,
                    color: AppTheme.primary,
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    appState.businessName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Proprietor: Business Owner",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.isCloudConnected ? "Cloud Sync: Connected" : "Local Storage Mode",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business_rounded, color: Color(0xFF94A3B8), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        appState.businessName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Statistics Grid (Dynamic)
            Row(
              children: [
                _buildStatItem("Catalog Size", "${appState.items.length} Items", Icons.inventory_2_rounded),
                const SizedBox(width: 10),
                _buildStatItem("Parties", "${appState.parties.length} Total", Icons.people_alt_rounded),
                const SizedBox(width: 10),
                _buildStatItem("Transactions", "${appState.transactions.length} Total", Icons.receipt_long_rounded),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Settings Grid
            const Text(
              "Account & Store Settings",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 10),

            _buildSettingsList(context),

            const SizedBox(height: 24),

            // 4. Quick Action Button (Switch/Logout Store)
            ThreeDButton(
              color: Colors.white,
              textColor: AppTheme.accentRed,
              borderColor: AppTheme.accentRed.withOpacity(0.3),
              icon: Icons.logout_rounded,
              text: "Switch Bookstore Database",
              onPressed: () {
                _showCompanySwitchSheet(context, appState);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: ThreeDContainer(
        depth: 3,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.warningOrange, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B)),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildSettingsRow(
          context,
          Icons.receipt_long_rounded,
          "Invoice & Print Settings",
          "Setup logo, thermal layouts, and headers",
        ),
        _buildSettingsRow(
          context,
          Icons.gavel_rounded,
          "Tax & GST Settings",
          "Manage tax categories and ledger formats",
        ),
        _buildSettingsRow(
          context,
          Icons.sync_lock_rounded,
          "Database Cloud Sync",
          "Linked with contact@surajbooks.com",
        ),
        _buildSettingsRow(
          context,
          Icons.people_outline_rounded,
          "Staff & Operators",
          "Manage catalog access controls",
        ),
      ],
    );
  }

  Widget _buildSettingsRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ThreeDContainer(
        depth: 2,
        borderRadius: 14,
        padding: const EdgeInsets.all(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Loading settings view for '$title'..."),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withOpacity(0.08),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
          ],
        ),
      ),
    );
  }

  void _showCompanySwitchSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Select Active Company",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.companies.length,
                    itemBuilder: (context, index) {
                      final company = state.companies[index];
                      final isActive = index == state.activeCompanyIndex;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ThreeDContainer(
                          depth: isActive ? 2 : 4,
                          borderRadius: 16,
                          color: isActive ? AppTheme.primary : Colors.white,
                          borderColor: isActive ? AppTheme.primary : const Color(0xFFE2E8F0),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          onTap: () {
                            state.switchCompany(index);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Switched to ${company.name}"),
                                backgroundColor: AppTheme.successGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.business_center_rounded,
                                color: isActive ? Colors.white : AppTheme.primary,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  company.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (isActive)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
