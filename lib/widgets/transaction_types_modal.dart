import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/sale_screen.dart';
import '../screens/payment_in_screen.dart';
import '../screens/sale_return_screen.dart';
import '../screens/sale_order_screen.dart';
import '../screens/estimate_quotation_screen.dart';
import '../screens/delivery_challan_screen.dart';
import '../screens/mobile_pos_screen.dart';
import '../screens/purchase_list_screen.dart';
import '../screens/payment_out_screen.dart';
import '../screens/purchase_return_screen.dart';
import '../screens/purchase_order_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../models/models.dart';

class TransactionTypesModal extends StatelessWidget {
  const TransactionTypesModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionTypesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Main Content Container
        Container(
          height: MediaQuery.of(context).size.height * 0.82,
          margin: const EdgeInsets.only(bottom: 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sale Transactions Section
                const Text(
                  "Sale Transactions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: [
                    _buildItem(
                      context: context,
                      label: "Sale invoices",
                      icon: Icons.receipt_long_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Take Payment",
                      icon: Icons.price_change_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentInScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Cr. Note/\nSale Return",
                      icon: Icons.assignment_return_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleReturnScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Sale Order",
                      icon: Icons.outbox_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleOrderScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Estimate/\nQuotation",
                      icon: Icons.description_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EstimateQuotationScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Proforma\nInvoice",
                      icon: Icons.note_alt_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EstimateQuotationScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Delivery\nChallan",
                      icon: Icons.local_shipping_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryChallanScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Mobile POS",
                      icon: Icons.receipt_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MobilePosScreen()));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Purchase Transactions Section
                const Text(
                  "Purchase Transactions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: [
                    _buildItem(
                      context: context,
                      label: "Purchase",
                      icon: Icons.shopping_cart_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseListScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Payment-Out",
                      icon: Icons.upload_sharp,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentOutScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Dr. Note/\nPurchase\nReturn",
                      icon: Icons.remove_shopping_cart_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseReturnScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Purchase\nOrder",
                      icon: Icons.business_center_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrderScreen()));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Other Transactions Section
                const Text(
                  "Other Transactions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: [
                    _buildItem(
                      context: context,
                      label: "Expenses",
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()));
                      },
                    ),
                    _buildItem(
                      context: context,
                      label: "Party\nTo Party\nTransfer",
                      icon: Icons.compare_arrows_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(initialType: TransactionType.sale),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Floating Dark Circular Close Button
        Positioned(
          bottom: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF232931),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Soft light blue pill background
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
              height: 1.15,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
