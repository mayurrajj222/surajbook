import 'package:flutter/material.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';
import 'sale_screen.dart';

class SaleOrderScreen extends StatefulWidget {
  const SaleOrderScreen({super.key});

  @override
  State<SaleOrderScreen> createState() => _SaleOrderScreenState();
}

class _SaleOrderScreenState extends State<SaleOrderScreen> {
  int _activeTab = 0; // 0 = Sale Orders, 1 = Online Orders
  int _activeFilter = 0; // 0 = All, 1 = Open Orders, 2 = Closed Orders, 3 = Partially...

  final List<String> _filters = ["All", "Open Orders", "Closed Orders", "Partially"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Orders",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Customized Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabItem("Sale Orders", 0),
                ),
                Expanded(
                  child: _buildTabItem("Online Orders", 1),
                ),
              ],
            ),
          ),

          // 2. Scrollable Filter Chips (Only for Sale Orders tab)
          if (_activeTab == 0)
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final label = _filters[index];
                  final isActive = _activeFilter == index;
                  return _buildFilterChip(label, index, isActive);
                },
              ),
            ),

          // 3. Main Content Body with Light Blue Background and Centered Illustration
          Expanded(
            child: Container(
              color: const Color(0xFFEFF6FF), // Soft light blue background matching screenshot
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Centered Illustration + Text
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Premium mockup document illustration
                        _buildDocumentIllustration(),
                        const SizedBox(height: 32),
                        const Text(
                          "Hey! You have no orders yet. Please add your sale order here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B), // Slate/grey text matching mockup
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 80), // Offset to prevent overlap with bottom button
                      ],
                    ),
                  ),

                  // 4. Pill-Shaped Add Sale Order Button at Bottom Center
                  Positioned(
                    bottom: 32,
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: const Text(
                          "Add Sale Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SaleScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFDC2626), // Vibrant red matching screenshot
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Pill-shaped stadium border
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int tabIndex) {
    final isActive = _activeTab == tabIndex;
    final color = isActive ? const Color(0xFFBE123C) : const Color(0xFF64748B); // Red for active, grey for inactive

    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabIndex;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // Underline indicator
          Container(
            height: 2,
            width: double.infinity,
            color: isActive ? const Color(0xFFBE123C) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isActive) {
    final textColor = isActive ? const Color(0xFFBE123C) : const Color(0xFF64748B);
    final borderColor = isActive ? const Color(0xFFBE123C) : const Color(0xFFE2E8F0);
    final bgColor = isActive ? const Color(0xFFFFF1F2) : Colors.white; // Very light pinkish-red background for active

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _activeFilter = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentIllustration() {
    return SizedBox(
      width: 180,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blue back curl representation
          Positioned(
            right: 25,
            bottom: 30,
            child: Container(
              width: 32,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E5CC0),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 35,
            child: Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // White document sheet
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2563EB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue header bar
                Container(
                  width: 50,
                  height: 10,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 12),
                // List lines
                Container(width: 70, height: 2, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 65, height: 2, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 50, height: 2, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 60, height: 2, color: Colors.grey.shade200),
              ],
            ),
          ),
          // Rupee coin on bottom-right of sheet
          Positioned(
            bottom: 22,
            right: 32,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24), // Gold/yellow color
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                "₹",
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
