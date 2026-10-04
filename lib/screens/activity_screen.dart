import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedPeriod = "This month";
  String _selectedUser = "All Users";
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 31),
  );

  final List<Map<String, String>> _activityFeed = [
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "18 Jul, 26 10:52 AM",
      "badge": "CREATED PAYMENT-IN",
      "refText": "Receipt Number : JMD2026-001",
    },
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "18 Jul, 26 10:50 AM",
      "badge": "CREATED PAYMENT-IN",
      "refText": "Receipt Number : JMD2026-002",
    },
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "18 Jul, 26 10:50 AM",
      "badge": "CREATED PAYMENT-IN",
      "refText": "Receipt Number : JMD2026-003",
    },
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "18 Jul, 26 10:48 AM",
      "badge": "MODIFIED ITEM",
      "refText": "Item Name : GM NURSERY SET",
    },
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "18 Jul, 26 10:48 AM",
      "badge": "CREATED SALE",
      "refText": "Invoice Number : JMD2026/INV-001",
    },
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "14 Jul, 26 01:44 PM",
      "badge": "MODIFIED PAYMENT-OUT",
      "refText": "Receipt Number : JMD2026-004",
    },
    {
      "userName": "Admin",
      "userRole": "Primary Admin",
      "time": "12 Jul, 26 04:15 PM",
      "badge": "CREATED PURCHASE",
      "refText": "Bill Number : PUR-2026-002",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3FC), // Soft blue backdrop matching reference image
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Activity",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // 1. Top Filters Section (White Container)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Row 1: Dropdown Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0284C7)),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                          items: ["This month", "Today", "This Quarter", "This Year"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPeriod = val);
                          },
                        ),
                      ),
                    ),
                    Container(height: 20, width: 1, color: Colors.grey.shade300),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUser,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0284C7)),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                          items: ["All Users", "Admin", "Staff 1"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUser = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: Date Range Box
                InkWell(
                  onTap: () => _selectDateRange(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF0284C7)),
                        const SizedBox(width: 12),
                        Text(
                          "${DateFormat('dd/MM/yyyy').format(_dateRange.start)}   to   ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Activity Cards Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _activityFeed.length,
              itemBuilder: (context, index) {
                final activity = _activityFeed[index];
                return _buildActivityCard(activity);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, String> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Part: User info & time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity["userName"]!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity["userRole"]!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Text(
                  activity["time"]!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Custom Dashed Divider Line
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: DashedLinePainter(),
          ),

          // Bottom Part: Badge & Reference text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pill badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    activity["badge"]!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Blue Reference text
                Expanded(
                  child: Text(
                    activity["refText"]!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
