// lib/screens/ShopOwner/owner_orders_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

const Duration kOrderExpireAfter = Duration(minutes: 2);

class OwnerOrdersScreen extends StatefulWidget {
  final VoidCallback? onOrdersSeen;
  const OwnerOrdersScreen({super.key, this.onOrdersSeen});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _open = true;

  bool _loading = true;
  bool _error = false;

  final List<_OwnerOrder> _newOrders = [];

  Timer? _uiTicker;
  Timer? _mockFeed;

  final String _shopName = "Charcoal Boutique";
  final String _shopCity = "Lahore";

  _SlideNoticeController? _notice;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _notice = _SlideNoticeController(this);

    // ✅ Defer badge-clearing callback until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onOrdersSeen?.call();
    });

    _boot();
  }


  Future<void> _boot() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    const bool simulateError = false;

    if (!mounted) return;

    if (simulateError) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    setState(() {
      _loading = false;
      _error = false;
    });

    _startTicker();
    _startMockFeed();

    _maybeAddIncomingOrder(force: true);
    _maybeAddIncomingOrder(force: true);
  }

  void _startTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _expireIfNeeded();
      if (mounted) setState(() {});
    });
  }

  void _startMockFeed() {
    _mockFeed?.cancel();
    _mockFeed = Timer.periodic(const Duration(seconds: 18), (_) {
      _maybeAddIncomingOrder();
    });
  }

  void _stopMockFeed() {
    _mockFeed?.cancel();
    _mockFeed = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiTicker?.cancel();
    _mockFeed?.cancel();
    _notice?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _expireIfNeeded();
      if (mounted) setState(() {});
    }
  }

  void _expireIfNeeded() {
    final now = DateTime.now();
    _newOrders.removeWhere((o) {
      final remaining = o.expiresAt.difference(now);
      if (remaining <= Duration.zero) {
        _showRedNotice("Order #${o.shortId} expired & moved to next shop");
        return true;
      }
      return false;
    });
  }

  void _maybeAddIncomingOrder({bool force = false}) {
    if (!_open) return;
    if (_loading || _error) return;

    final allow = force || (DateTime.now().second % 2 == 0);
    if (!allow) return;

    final created = DateTime.now();
    final order = _OwnerOrder.mock(createdAt: created);
    setState(() => _newOrders.insert(0, order));

    HapticFeedback.mediumImpact();
    _showRedNotice("New order received (#${order.shortId})");
  }

  Future<void> _confirmReject(_OwnerOrder o) async {
    final ok = await _confirmDialog(
      title: "Reject order?",
      body: "Are you sure you want to reject Order #${o.shortId}? This cannot be undone.",
      confirmText: "Reject",
      danger: true,
    );
    if (!ok) return;

    setState(() => _newOrders.removeWhere((x) => x.id == o.id));
    _showRedNotice("Order #${o.shortId} rejected");
  }

  Future<void> _confirmAccept(_OwnerOrder o) async {
    final ok = await _confirmDialog(
      title: "Accept order?",
      body: "Accept Order #${o.shortId}? It will move to Accepted Orders and rider assignment will start.",
      confirmText: "Accept",
    );
    if (!ok) return;

    setState(() => _newOrders.removeWhere((x) => x.id == o.id));
    _showRedNotice("Order #${o.shortId} accepted");
  }

  Future<bool> _confirmDialog({
    required String title,
    required String body,
    required String confirmText,
    bool danger = false,
  }) async {
    HapticFeedback.selectionClick();
    return (await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Glass(
              borderRadius: AppRadius.r24,
              sigmaX: 22,
              sigmaY: 22,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              color: Colors.white.withOpacity(0.84),
              borderColor: Colors.white.withOpacity(0.90),
              shadows: AppShadows.shadowLg,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.h2()),
                    const SizedBox(height: 8),
                    Text(body, style: AppText.body()),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: PressScale(
                            borderRadius: AppRadius.pill(),
                            onTap: () => Navigator.pop(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.62),
                                borderRadius: AppRadius.pill(),
                                border: Border.all(
                                  color: AppColors.divider.withOpacity(0.55),
                                  width: 1.05,
                                ),
                              ),
                              child: Center(child: Text("Cancel", style: AppText.button())),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PressScale(
                            borderRadius: AppRadius.pill(),
                            onTap: () => Navigator.pop(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              decoration: BoxDecoration(
                                gradient: danger
                                    ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.danger, AppColors.danger.withOpacity(0.85)],
                                )
                                    : AppColors.brandLinear,
                                borderRadius: AppRadius.pill(),
                                border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.1),
                                boxShadow: AppShadows.soft,
                              ),
                              child: Center(
                                child: Text(
                                  confirmText,
                                  style: AppText.button().copyWith(color: Colors.white.withOpacity(0.95)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    )) ??
        false;
  }

  void _showRedNotice(String msg) {
    _notice?.show(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ content-only (Shell handles background + nav)
    return Stack(
      children: [
        Column(
          children: [
            _TopHeader(
              shopName: _shopName,
              shopCity: _shopCity,
              open: _open,
              newCount: _newOrders.length,
              onToggleOpen: (v) {
                setState(() => _open = v);
                HapticFeedback.lightImpact();

                if (!_open) {
                  _stopMockFeed();
                  _showRedNotice("Shop CLOSED — new orders paused");
                } else {
                  _startMockFeed();
                  _showRedNotice("Shop OPEN — receiving orders");
                  _maybeAddIncomingOrder(force: true);
                }
              },
              onProfileTap: () => _showRedNotice("Open Account from bottom tab"),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _BodyCard(
                loading: _loading,
                error: _error,
                open: _open,
                newOrders: _newOrders,
                onRetry: _boot,
                onSimulateNew: () => _maybeAddIncomingOrder(force: true),
                onReject: _confirmReject,
                onAccept: _confirmAccept,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _TopHeader extends StatelessWidget {
  final String shopName;
  final String shopCity;
  final bool open;
  final int newCount;
  final ValueChanged<bool> onToggleOpen;
  final VoidCallback onProfileTap;

  const _TopHeader({
    required this.shopName,
    required this.shopCity,
    required this.open,
    required this.newCount,
    required this.onToggleOpen,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ same colors as your dashboard / customer theme
    const primary = Color(0xFF440C08);
    const secondary = Color(0xFF750A03);

    final statusColor = open ? AppColors.success : AppColors.danger;
    final r = BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withOpacity(0.96),
                secondary.withOpacity(0.92),
                primary.withOpacity(0.94),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ✅ subtle glow blob (like dashboard header)
              Positioned(
                right: -46,
                top: -42,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  // store icon puck
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.96),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.30),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              open ? "OPEN • $shopCity" : "CLOSED • $shopCity",
                              style: GoogleFonts.manrope(
                                fontSize: 12.2,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.78),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (newCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.white.withOpacity(0.14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.22),
                                    width: 1.0,
                                  ),
                                ),
                                // child: Text(
                                //   "$newCount NEW",
                                //   style: GoogleFonts.manrope(
                                //     fontSize: 11.2,
                                //     fontWeight: FontWeight.w900,
                                //     color: Colors.white.withOpacity(0.92),
                                //   ),
                                // ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // profile icon (glass)
                  PressScale(
                    borderRadius: AppRadius.pill(),
                    downScale: 0.97,
                    onTap: onProfileTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: AppRadius.pill(),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 18.5,
                        color: Colors.white.withOpacity(0.90),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ✅ same toggle component you already had
                  _OpenCloseToggle(value: open, onChanged: onToggleOpen),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _OpenCloseToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OpenCloseToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = value ? "OPEN" : "CLOSED";
    final chipColor = value ? AppColors.success : AppColors.danger;

    return PressScale(
      borderRadius: AppRadius.pill(),
      downScale: 0.98,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill(),
          color: Colors.white.withOpacity(0.62),
          border: Border.all(color: AppColors.divider.withOpacity(0.55), width: 1.05),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 22,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: AppRadius.pill(),
                color: Colors.white.withOpacity(0.70),
                border: Border.all(color: AppColors.divider.withOpacity(0.50), width: 1.0),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandLinear,
                    boxShadow: AppShadows.soft,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: AppRadius.pill(),
                color: chipColor.withOpacity(0.12),
                border: Border.all(color: chipColor.withOpacity(0.25), width: 1.0),
              ),
              child: Text(
                label,
                style: AppText.kicker().copyWith(color: chipColor, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body + cards + states (unchanged)
// ─────────────────────────────────────────────

class _BodyCard extends StatelessWidget {
  final bool loading;
  final bool error;
  final bool open;
  final List<_OwnerOrder> newOrders;
  final Future<void> Function() onRetry;
  final VoidCallback onSimulateNew;
  final Future<void> Function(_OwnerOrder) onReject;
  final Future<void> Function(_OwnerOrder) onAccept;

  const _BodyCard({
    required this.loading,
    required this.error,
    required this.open,
    required this.newOrders,
    required this.onRetry,
    required this.onSimulateNew,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      borderRadius: AppRadius.r24,
      sigmaX: 18,
      sigmaY: 18,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withOpacity(0.66),
      borderColor: Colors.white.withOpacity(0.84),
      shadows: AppShadows.shadowLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("New Orders", style: AppText.h3()),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pill(),
                  color: Colors.white.withOpacity(0.66),
                  border: Border.all(color: AppColors.divider.withOpacity(0.55), width: 1.0),
                ),
                child: Text(
                  "${newOrders.length}",
                  style: AppText.kicker().copyWith(
                    color: AppColors.ink.withOpacity(0.72),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              GlassPill(text: "Simulate", onTap: onSimulateNew),
            ],
          ),
          const SizedBox(height: 10),
          if (loading) ...[
            const _LoadingState(),
          ] else if (error) ...[
            _ErrorState(onRetry: onRetry),
          ] else if (!open) ...[
            const _ClosedState(),
          ] else if (newOrders.isEmpty) ...[
            const _EmptyState(),
          ] else ...[
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: newOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = newOrders[i];
                  return _NewOrderCard(
                    order: o,
                    onReject: () => onReject(o),
                    onAccept: () => onAccept(o),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NewOrderCard extends StatelessWidget {
  final _OwnerOrder order;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const _NewOrderCard({
    required this.order,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = order.expiresAt.difference(now);
    final r = remaining.isNegative ? Duration.zero : remaining;

    final mm = r.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = r.inSeconds.remainder(60).toString().padLeft(2, '0');

    final urgency = r.inSeconds <= 20;
    final badgeColor = urgency ? AppColors.danger : AppColors.warning;

    return Glass(
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
                  color: badgeColor.withOpacity(0.12),
                  border: Border.all(color: badgeColor.withOpacity(0.22), width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_rounded, size: 15, color: badgeColor.withOpacity(0.95)),
                    const SizedBox(width: 6),
                    Text(
                      "$mm:$ss left",
                      style: AppText.kicker().copyWith(
                        color: badgeColor.withOpacity(0.95),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetaChip(icon: Icons.shopping_bag_rounded, text: "${order.items.length} items"),
              const SizedBox(width: 8),
              _MetaChip(icon: Icons.payments_rounded, text: "Rs ${order.total.toStringAsFixed(0)}"),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaChip(icon: Icons.local_shipping_rounded, text: order.deliveryLabel),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: order.items.take(2).map((it) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.r12,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.16),
                            AppColors.secondary.withOpacity(0.10),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.60), width: 1.0),
                      ),
                      child: Icon(Icons.checkroom_rounded, size: 16, color: AppColors.ink.withOpacity(0.62)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${it.name} • ${it.variant}",
                        style: AppText.body(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("x${it.qty}", style: AppText.kicker()),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PressScale(
                  borderRadius: AppRadius.pill(),
                  downScale: 0.98,
                  onTap: onReject,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.62),
                      borderRadius: AppRadius.pill(),
                      border: Border.all(color: AppColors.danger.withOpacity(0.25), width: 1.1),
                    ),
                    child: Center(
                      child: Text(
                        "Reject",
                        style: AppText.button().copyWith(color: AppColors.danger.withOpacity(0.92)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PressScale(
                  borderRadius: AppRadius.pill(),
                  downScale: 0.98,
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandLinear,
                      borderRadius: AppRadius.pill(),
                      border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.1),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Center(
                      child: Text(
                        "Accept",
                        style: AppText.button().copyWith(color: Colors.white.withOpacity(0.95)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: Colors.white.withOpacity(0.60),
        border: Border.all(color: AppColors.divider.withOpacity(0.48), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.ink.withOpacity(0.72)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppText.kicker().copyWith(
                color: AppColors.ink.withOpacity(0.70),
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── states (unchanged)
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = 1}) => Container(
      height: 12,
      width: MediaQuery.of(context).size.width * w,
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: Colors.white.withOpacity(0.55),
        border: Border.all(color: AppColors.divider.withOpacity(0.40), width: 1.0),
      ),
    );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(w: 0.55),
          const SizedBox(height: 12),
          bar(w: 0.80),
          const SizedBox(height: 12),
          bar(w: 0.65),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => Container(
                height: 118,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.r18,
                  color: Colors.white.withOpacity(0.55),
                  border: Border.all(color: AppColors.divider.withOpacity(0.40), width: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.72),
          borderColor: Colors.white.withOpacity(0.86),
          shadows: AppShadows.soft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 34, color: AppColors.ink.withOpacity(0.75)),
              const SizedBox(height: 10),
              Text("Failed to load orders", style: AppText.h3()),
              const SizedBox(height: 6),
              Text("Check your connection and try again.",
                  style: AppText.subtle(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              BrandButton(text: "Retry", onTap: () => onRetry()),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 42, color: AppColors.ink.withOpacity(0.35)),
            const SizedBox(height: 10),
            Text("No new orders", style: AppText.h3()),
            const SizedBox(height: 6),
            Text("You’re all caught up. New orders will appear here.",
                style: AppText.subtle(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ClosedState extends StatelessWidget {
  const _ClosedState();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.72),
          borderColor: Colors.white.withOpacity(0.86),
          shadows: AppShadows.soft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 36, color: AppColors.danger.withOpacity(0.85)),
              const SizedBox(height: 10),
              Text("Shop is Closed", style: AppText.h3()),
              const SizedBox(height: 6),
              Text("Turn OPEN to start receiving new orders.",
                  style: AppText.subtle(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Slide notice (unchanged)
// ─────────────────────────────────────────────

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
      right: 14,
      left: 14,
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

// ─────────────────────────────────────────────
// Mock models (unchanged)
// ─────────────────────────────────────────────

class _OwnerOrder {
  final String id;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String deliveryLabel;
  final List<_OwnerOrderItem> items;
  final double total;

  _OwnerOrder({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.deliveryLabel,
    required this.items,
    required this.total,
  });

  String get shortId => id.split("-").last;

  static int _counter = 120;

  static _OwnerOrder mock({required DateTime createdAt}) {
    _counter++;
    final id = "ORD-$_counter";
    final expiresAt = createdAt.add(kOrderExpireAfter);

    final sample = <_OwnerOrderItem>[
      _OwnerOrderItem(name: "Black T-Shirt", variant: "M • Black", qty: 2, price: 1299),
      _OwnerOrderItem(name: "Light Blue Shirt", variant: "L • Sky", qty: 1, price: 2199),
      _OwnerOrderItem(name: "Formal Pants", variant: "32 • Charcoal", qty: 1, price: 2499),
      _OwnerOrderItem(name: "Hoodie", variant: "L • Maroon", qty: 1, price: 2799),
    ];

    final start = _counter % (sample.length - 1);
    final items = sample.sublist(start, start + 2);

    final total = items.fold<double>(0, (sum, it) => sum + (it.qty * it.price));

    return _OwnerOrder(
      id: id,
      createdAt: createdAt,
      expiresAt: expiresAt,
      deliveryLabel: (createdAt.second % 3 == 0) ? "Delivery" : "Pickup",
      items: items,
      total: total,
    );
  }
}

class _OwnerOrderItem {
  final String name;
  final String variant;
  final int qty;
  final double price;

  _OwnerOrderItem({
    required this.name,
    required this.variant,
    required this.qty,
    required this.price,
  });
}
