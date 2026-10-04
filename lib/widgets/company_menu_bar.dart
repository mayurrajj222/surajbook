import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'three_d_button.dart';

class CompanyMenuBar extends StatelessWidget {
  const CompanyMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC), // subtle cool background
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: state.companies.length + 1,
        itemBuilder: (context, index) {
          if (index == state.companies.length) {
            // "Add Company" button
            return Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: ThreeDButton(
                width: 145,
                height: 44,
                borderRadius: 12,
                depth: 2,
                color: Colors.white,
                borderColor: AppTheme.primary.withOpacity(0.3),
                textColor: AppTheme.primary,
                onPressed: () {
                  _showAddCompanyDialog(context, state);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.primary),
                    SizedBox(width: 6),
                    Text(
                      "Add Company",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
            );
          }

          final company = state.companies[index];
          final isActive = index == state.activeCompanyIndex;
          final activeColor = AppTheme.primary;

          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : 8.0),
            child: ThreeDButton(
              width: 175,
              height: 44,
              borderRadius: 12,
              depth: isActive ? 4 : 2,
              color: isActive ? activeColor : Colors.white,
              textColor: isActive ? Colors.white : const Color(0xFF475569),
              borderColor: isActive ? activeColor : const Color(0xFFCBD5E1),
              onPressed: () {
                state.switchCompany(index);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_center_rounded,
                    size: 15,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      company.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : const Color(0xFF475569),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCompanyDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Create New Company", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter the name of your new company/firm to manage separate books, parties, and items.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Company Name",
                hintText: "e.g. Suraj Electronics",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.business_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                state.addCompany(text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Switched to new company: $text"),
                    backgroundColor: AppTheme.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
