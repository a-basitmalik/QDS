import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

import 'order_details_screen.dart';

/// ✅ OrdersScreen (CONTENT-ONLY)
/// - 4 sections: Accepted, In-Process, Rejected, Completed
/// - Tap order -> OrderDetailsScreen (NO bottom nav there)
/// - Shell provides background + bottom nav
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  // Mock store
  final List<OwnerOrder> _accepted = [];
  final List<OwnerOrder> _inProcess = [];
  final List<OwnerOrder> _rejected = [];
  final List<OwnerOrder> _completed = [];

  // UI ticker for rider ETA refresh
  Timer? _ticker;

  // Slide notice (red)
  _SlideNoticeController? _notice;

  @override
  void initState() {
    super.initState();
    _notice = _SlideNoticeController(this);
    _seedMock();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notice?.dispose();
    super.dispose();
  }

  void _seedMock() {
    final now = DateTime.now();

    _accepted.addAll([
      OwnerOrder.mock(
        status: OwnerOrderStatus.accepted,
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      OwnerOrder.mock(
        status: OwnerOrderStatus.accepted,
        createdAt: now.subtract(const Duration(minutes: 7)),
      ),
    ]);

    _inProcess.addAll([
      OwnerOrder.mock(
        status: OwnerOrderStatus.inProcess,
        createdAt: now.subtract(const Duration(minutes: 14)),
      ),
    ]);

    _rejected.addAll([
      OwnerOrder.mock(
        status: OwnerOrderStatus.rejected,
        createdAt: now.subtract(const Duration(minutes: 21)),
      ),
    ]);

    _completed.addAll([
      OwnerOrder.mock(
        status: OwnerOrderStatus.completed,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
      OwnerOrder.mock(
        status: OwnerOrderStatus.completed,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 35)),
      ),
    ]);
  }

  void _showRedNotice(String msg) => _notice?.show(context, msg);

  Future<void> _openDetails(OwnerOrder order) async {
    final result = await Navigator.push<OrderDetailsResult>(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );

    if (result == null) return;

    _removeFromAll(order.id);
    final updated = order.copyWith(status: result.newStatus);

    switch (result.newStatus) {
      case OwnerOrderStatus.accepted:
        _accepted.insert(0, updated);
        break;
      case OwnerOrderStatus.inProcess:
        _inProcess.insert(0, updated);
        break;
      case OwnerOrderStatus.rejected:
        _rejected.insert(0, updated);
        break;
      case OwnerOrderStatus.completed:
        _completed.insert(0, updated);
        break;
    }

    setState(() {});
    _showRedNotice("Order #${order.shortId} → ${result.newStatus.label}");
  }

  void _removeFromAll(String id) {
    _accepted.removeWhere((o) => o.id == id);
    _inProcess.removeWhere((o) => o.id == id);
    _rejected.removeWhere((o) => o.id == id);
    _completed.removeWhere((o) => o.id == id);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ content-only (Shell handles bg + nav)
    return _OrdersBody(
      accepted: _accepted,
      inProcess: _inProcess,
      rejected: _rejected,
      completed: _completed,
      onTapOrder: _openDetails,
    );
  }
}

/// ─────────────────────────────────────────────
/// Orders body UI
/// ─────────────────────────────────────────────

class _OrdersBody extends StatefulWidget {
  final List<OwnerOrder> accepted;
  final List<OwnerOrder> inProcess;
  final List<OwnerOrder> rejected;
  final List<OwnerOrder> completed;
  final Future<void> Function(OwnerOrder) onTapOrder;

  const _OrdersBody({
    required this.accepted,
    required this.inProcess,
    required this.rejected,
    required this.completed,
    required this.onTapOrder,
  });

  @override
  State<_OrdersBody> createState() => _OrdersBodyState();
}

class _OrdersBodyState extends State<_OrdersBody> {
  OwnerOrderStatus _filter = OwnerOrderStatus.accepted;

  @override
  Widget build(BuildContext context) {
    final list = switch (_filter) {
      OwnerOrderStatus.accepted => widget.accepted,
      OwnerOrderStatus.inProcess => widget.inProcess,
      OwnerOrderStatus.rejected => widget.rejected,
      OwnerOrderStatus.completed => widget.completed,
    };

    return Column(
      children: [
        Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          color: Colors.white.withOpacity(0.72),
          borderColor: Colors.white.withOpacity(0.86),
          shadows: AppShadows.soft,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.brandLinear,
                  borderRadius: AppRadius.r16,
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(Icons.receipt_long_rounded,
                    color: Colors.white.withOpacity(0.96)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Orders", style: AppText.h2()),
                    const SizedBox(height: 4),
                    Text(
                      "Accepted, In-Process, Rejected, Completed",
                      style: AppText.subtle(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pill(),
                  color: Colors.white.withOpacity(0.68),
                  border: Border.all(
                    color: AppColors.divider.withOpacity(0.55),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  "${list.length}",
                  style: AppText.kicker().copyWith(
                    color: AppColors.ink.withOpacity(0.72),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),

        _StatusTabs(
          value: _filter,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _filter = v);
          },
          counts: _StatusCounts(
            accepted: widget.accepted.length,
            inProcess: widget.inProcess.length,
            rejected: widget.rejected.length,
            completed: widget.completed.length,
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: Glass(
            borderRadius: AppRadius.r24,
            sigmaX: 18,
            sigmaY: 18,
            padding: const EdgeInsets.all(14),
            color: Colors.white.withOpacity(0.66),
            borderColor: Colors.white.withOpacity(0.84),
            shadows: AppShadows.shadowLg,
            child: list.isEmpty
                ? Center(child: Text("No orders here", style: AppText.h3()))
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final o = list[i];
                return _OrderRowCard(
                  order: o,
                  onTap: () => widget.onTapOrder(o),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCounts {
  final int accepted, inProcess, rejected, completed;
  const _StatusCounts({
    required this.accepted,
    required this.inProcess,
    required this.rejected,
    required this.completed,
  });
}

class _StatusTabs extends StatelessWidget {
  final OwnerOrderStatus value;
  final ValueChanged<OwnerOrderStatus> onChanged;
  final _StatusCounts counts;

  const _StatusTabs({
    required this.value,
    required this.onChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      borderRadius: AppRadius.r22,
      sigmaX: 18,
      sigmaY: 18,
      padding: const EdgeInsets.all(10),
      color: Colors.white.withOpacity(0.70),
      borderColor: Colors.white.withOpacity(0.86),
      shadows: AppShadows.soft,
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              active: value == OwnerOrderStatus.accepted,
              label: "Accepted",
              count: counts.accepted,
              onTap: () => onChanged(OwnerOrderStatus.accepted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabChip(
              active: value == OwnerOrderStatus.inProcess,
              label: "In-Process",
              count: counts.inProcess,
              onTap: () => onChanged(OwnerOrderStatus.inProcess),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabChip(
              active: value == OwnerOrderStatus.rejected,
              label: "Rejected",
              count: counts.rejected,
              onTap: () => onChanged(OwnerOrderStatus.rejected),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabChip(
              active: value == OwnerOrderStatus.completed,
              label: "Completed",
              count: counts.completed,
              onTap: () => onChanged(OwnerOrderStatus.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final bool active;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _TabChip({
    required this.active,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg =
    active ? Colors.white.withOpacity(0.96) : AppColors.ink.withOpacity(0.74);

    return PressScale(
      borderRadius: AppRadius.pill(),
      downScale: 0.985,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill(),
          gradient: active ? AppColors.brandLinear : null,
          color: active ? null : Colors.white.withOpacity(0.60),
          border: Border.all(
            color: active
                ? Colors.white.withOpacity(0.22)
                : AppColors.divider.withOpacity(0.50),
            width: 1.05,
          ),
          boxShadow: active ? AppShadows.soft : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppText.kicker().copyWith(color: fg),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: AppRadius.pill(),
                color: active
                    ? Colors.white.withOpacity(0.16)
                    : Colors.white.withOpacity(0.70),
                border: Border.all(
                  color: active
                      ? Colors.white.withOpacity(0.22)
                      : AppColors.divider.withOpacity(0.50),
                  width: 1.0,
                ),
              ),
              child: Text(
                "$count",
                style: AppText.kicker().copyWith(color: fg),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _OrderRowCard extends StatelessWidget {
  final OwnerOrder order;
  final VoidCallback onTap;

  const _OrderRowCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status.color;
    final etaText = order.riderEtaMinutes == null
        ? "ETA: --"
        : "ETA: ${order.riderEtaMinutes} min";

    return PressScale(
      borderRadius: AppRadius.r22,
      downScale: 0.992,
      onTap: onTap,
      child: Glass(
        borderRadius: AppRadius.r22,
        sigmaX: 18,
        sigmaY: 18,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        color: Colors.white.withOpacity(0.72),
        borderColor: Colors.white.withOpacity(0.86),
        shadows: AppShadows.soft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Order #${order.shortId}", style: AppText.h3()),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pill(),
                    color: statusColor.withOpacity(0.12),
                    border: Border.all(
                        color: statusColor.withOpacity(0.22), width: 1.0),
                  ),
                  child: Text(
                    order.status.label,
                    style: AppText.kicker().copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniChip(
                    icon: Icons.shopping_bag_rounded,
                    text: "${order.items.length} items"),
                const SizedBox(width: 8),
                _MiniChip(
                    icon: Icons.payments_rounded,
                    text: "Rs ${order.total.toStringAsFixed(0)}"),
                const SizedBox(width: 8),
                Expanded(child: _MiniChip(icon: Icons.timer_rounded, text: etaText)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "${order.items.first.name} • ${order.items.first.variant}",
              style: AppText.body(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: Colors.white.withOpacity(0.60),
        border:
        Border.all(color: AppColors.divider.withOpacity(0.48), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.ink.withOpacity(0.72)),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.kicker().copyWith(
              color: AppColors.ink.withOpacity(0.70),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Slide notice (red)
/// ─────────────────────────────────────────────

class _SlideNoticeController {
  final TickerProvider vsync;
  late final AnimationController ctrl;
  late final Animation<Offset> slide;
  late final Animation<double> fade;

  OverlayEntry? _entry;
  Timer? _hideTimer;

  _SlideNoticeController(this.vsync) {
    ctrl = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 240));
    slide = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic));
    fade = CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);
  }

  void show(BuildContext context, String text) {
    _hideTimer?.cancel();
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (_) => _SlideNotice(slide: slide, fade: fade, text: text),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
    ctrl.forward(from: 0);

    _hideTimer = Timer(const Duration(seconds: 3), () async {
      await ctrl.reverse();
      _entry?.remove();
      _entry = null;
    });
  }

  void dispose() {
    _hideTimer?.cancel();
    ctrl.dispose();
  }
}

class _SlideNotice extends StatelessWidget {
  final Animation<Offset> slide;
  final Animation<double> fade;
  final String text;

  const _SlideNotice({
    required this.slide,
    required this.fade,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 10,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: Glass(
            borderRadius: AppRadius.r22,
            sigmaX: 18,
            sigmaY: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: AppColors.danger.withOpacity(0.92),
            borderColor: Colors.white.withOpacity(0.16),
            shadows: AppShadows.soft,
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: Colors.white.withOpacity(0.96), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: AppText.body().copyWith(color: Colors.white.withOpacity(0.96)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// PUBLIC Models (used by OrderDetailsScreen too)
/// ─────────────────────────────────────────────

enum OwnerOrderStatus { accepted, inProcess, rejected, completed }

extension OwnerOrderStatusX on OwnerOrderStatus {
  String get label => switch (this) {
    OwnerOrderStatus.accepted => "ACCEPTED",
    OwnerOrderStatus.inProcess => "IN PROCESS",
    OwnerOrderStatus.rejected => "REJECTED",
    OwnerOrderStatus.completed => "COMPLETED",
  };

  Color get color => switch (this) {
    OwnerOrderStatus.accepted => AppColors.success,
    OwnerOrderStatus.inProcess => AppColors.warning,
    OwnerOrderStatus.rejected => AppColors.danger,
    OwnerOrderStatus.completed => AppColors.primary,
  };
}

class OwnerOrder {
  final String id;
  final DateTime createdAt;
  final OwnerOrderStatus status;
  final String deliveryLabel;
  final List<OwnerOrderItem> items;
  final double total;

  final String riderName;
  final String riderPhone;
  final int? riderEtaMinutes;

  OwnerOrder({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.deliveryLabel,
    required this.items,
    required this.total,
    required this.riderName,
    required this.riderPhone,
    required this.riderEtaMinutes,
  });

  String get shortId => id.split("-").last;

  OwnerOrder copyWith({OwnerOrderStatus? status, int? riderEtaMinutes}) {
    return OwnerOrder(
      id: id,
      createdAt: createdAt,
      status: status ?? this.status,
      deliveryLabel: deliveryLabel,
      items: items,
      total: total,
      riderName: riderName,
      riderPhone: riderPhone,
      riderEtaMinutes: riderEtaMinutes ?? this.riderEtaMinutes,
    );
  }

  static int _counter = 200;

  static OwnerOrder mock({required OwnerOrderStatus status, required DateTime createdAt}) {
    _counter++;
    final id = "ORD-$_counter";

    final sample = <OwnerOrderItem>[
      OwnerOrderItem(name: "Light Blue Shirt", variant: "L • Sky", qty: 1, price: 2199),
      OwnerOrderItem(name: "Formal Pants", variant: "32 • Charcoal", qty: 1, price: 2499),
      OwnerOrderItem(name: "Hoodie", variant: "L • Maroon", qty: 1, price: 2799),
      OwnerOrderItem(name: "Black T-Shirt", variant: "M • Black", qty: 2, price: 1299),
    ];

    final start = _counter % (sample.length - 1);
    final items = sample.sublist(start, start + 2);

    final total = items.fold<double>(0, (sum, it) => sum + (it.qty * it.price));

    final eta = (status == OwnerOrderStatus.accepted || status == OwnerOrderStatus.inProcess)
        ? (12 + (_counter % 10))
        : null;

    return OwnerOrder(
      id: id,
      createdAt: createdAt,
      status: status,
      deliveryLabel: (createdAt.second % 3 == 0) ? "Delivery" : "Pickup",
      items: items,
      total: total,
      riderName: "Ali Rider",
      riderPhone: "+92 3${(_counter % 9)}0 1234567",
      riderEtaMinutes: eta,
    );
  }
}

class OwnerOrderItem {
  final String name;
  final String variant;
  final int qty;
  final double price;

  OwnerOrderItem({
    required this.name,
    required this.variant,
    required this.qty,
    required this.price,
  });
}

/// Returned from OrderDetailsScreen to update lists
class OrderDetailsResult {
  final OwnerOrderStatus newStatus;
  const OrderDetailsResult(this.newStatus);
}
