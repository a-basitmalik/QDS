import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

class ShopOrderManagementScreen extends StatefulWidget {
  const ShopOrderManagementScreen({super.key});

  @override
  State<ShopOrderManagementScreen> createState() =>
      _ShopOrderManagementScreenState();
}

class _ShopOrderManagementScreenState
    extends State<ShopOrderManagementScreen> {
  final List<_IncomingOrder> _orders = [];
  Timer? _mockIncomingTimer;

  @override
  void initState() {
    super.initState();

    // 🔁 MOCK: new order every 12 seconds
    _mockIncomingTimer =
        Timer.periodic(const Duration(seconds: 12), (_) {
          _addIncomingOrder();
        });
  }

  @override
  void dispose() {
    _mockIncomingTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // MOCK NEW ORDER
  // ─────────────────────────────────────────────────────────────

  void _addIncomingOrder() {
    final order = _IncomingOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: "Classic Watch",
      qty: 1,
      price: 4999,
      eta: "25–35 min",
    );

    setState(() => _orders.insert(0, order));

    _showNewOrderPopup(order);
  }

  // ─────────────────────────────────────────────────────────────
  // POPUP FOR NEW ORDER
  // ─────────────────────────────────────────────────────────────

  void _showNewOrderPopup(_IncomingOrder order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NewOrderDialog(
        order: order,
        onAccept: () => _acceptOrder(order),
        onReject: () => _rejectOrder(order),
        onTimeout: () => _timeoutOrder(order),
      ),
    );
  }

  void _acceptOrder(_IncomingOrder order) {
    Navigator.pop(context);
    setState(() => order.status = OrderStatus.accepted);
  }

  void _rejectOrder(_IncomingOrder order) {
    Navigator.pop(context);
    setState(() => order.status = OrderStatus.outOfStock);
  }

  void _timeoutOrder(_IncomingOrder order) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() => order.status = OrderStatus.timedOut);
  }

  // ─────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Order Management"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _orderCard(_orders[i]),
      ),
    );
  }

  Widget _orderCard(_IncomingOrder order) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusText = "Awaiting response";
        break;
      case OrderStatus.accepted:
        statusColor = Colors.green;
        statusText = "Accepted";
        break;
      case OrderStatus.outOfStock:
        statusColor = Colors.red;
        statusText = "Out of stock";
        break;
      case OrderStatus.timedOut:
        statusColor = Colors.grey;
        statusText = "Timed out";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.product,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Qty: ${order.qty} • Rs. ${order.price}",
            style: AppText.body14Soft,
          ),
          const SizedBox(height: 6),
          Text(
            "Delivery ETA: ${order.eta}",
            style: AppText.body14Soft,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),

              if (order.status == OrderStatus.pending) ...[
                TextButton(
                  onPressed: () => _rejectOrder(order),
                  child: const Text("Out of stock"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _acceptOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Accept"),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


class _NewOrderDialog extends StatefulWidget {
  final _IncomingOrder order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTimeout;

  const _NewOrderDialog({
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onTimeout,
  });

  @override
  State<_NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<_NewOrderDialog> {
  static const int maxSeconds = 60;
  int secondsLeft = maxSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => secondsLeft--);
      if (secondsLeft <= 0) {
        t.cancel();
        widget.onTimeout();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "New Order Request",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              widget.order.product,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              "Qty: ${widget.order.qty} • Rs. ${widget.order.price}",
              style: AppText.body14Soft,
            ),
            const SizedBox(height: 6),
            Text(
              "Delivery ETA: ${widget.order.eta}",
              style: AppText.body14Soft,
            ),

            const SizedBox(height: 14),

            LinearProgressIndicator(
              value: secondsLeft / maxSeconds,
              backgroundColor: AppColors.divider,
              color: Colors.orange,
            ),
            const SizedBox(height: 6),
            Text(
              "Respond within $secondsLeft seconds",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReject,
                    child: const Text("Out of stock"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum OrderStatus { pending, accepted, outOfStock, timedOut }

class _IncomingOrder {
  final String id;
  final String product;
  final int qty;
  final int price;
  final String eta;
  OrderStatus status;

  _IncomingOrder({
    required this.id,
    required this.product,
    required this.qty,
    required this.price,
    required this.eta,
    this.status = OrderStatus.pending,
  });
}
