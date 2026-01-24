// lib/screens/ShopOwner/owner_dashboard_screen.dart
import 'dart:math';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner_promotions_screen.dart';     // the promotions create screen you already got
import 'owner_flash_deals_screen.dart';
import 'dart:convert';


// new screen above
class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenOrders;

  // ✅ NEW: receive owner id from login
  final int ownerUserId;

  const OwnerDashboardScreen({
    super.key,
    required this.onOpenOrders,
    required this.ownerUserId,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}
class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with TickerProviderStateMixin {
  // ✅ Theme (match your customer reference)
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const String _baseUrl = "http://31.97.190.216:10050";

  bool _loadingCurrentPromos = true;
  List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _flashDeals = [];

  static const _ink = Color(0xFF140504);

  // mock shop state
  bool _open = true;

  // mock stats
  final double _totalSales = 248500; // Rs
  final double _receivable = 42100;  // Rs pending
  final int _inventoryLeft = 186;    // items
  final int _processing = 7;
  final int _deliveredToday = 18;

  late final AnimationController _ambientCtrl;
  Uri _promoListUri() => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.ownerUserId}/promotions?owner_user_id=${widget.ownerUserId}",
  );

  Uri _flashListUri() => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.ownerUserId}/flash-deals?owner_user_id=${widget.ownerUserId}",
  );

  Uri _flashDeleteUri(int dealId) => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.ownerUserId}/flash-deals/$dealId?owner_user_id=${widget.ownerUserId}",
  );

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5400),
    )..repeat(reverse: true);

    _loadCurrentPromotions();
  }

  Future<void> _loadCurrentPromotions() async {
    try {
      setState(() => _loadingCurrentPromos = true);

      final pRes = await http.get(_promoListUri()).timeout(const Duration(seconds: 15));
      final dRes = await http.get(_flashListUri()).timeout(const Duration(seconds: 15));

      final pj = jsonDecode(pRes.body);
      final dj = jsonDecode(dRes.body);

      setState(() {
        _promos = (pRes.statusCode == 200 && pj["ok"] == true)
            ? (pj["data"] as List).cast<Map<String, dynamic>>()
            : [];
        _flashDeals = (dRes.statusCode == 200 && dj["ok"] == true)
            ? (dj["data"] as List).cast<Map<String, dynamic>>()
            : [];
        _loadingCurrentPromos = false;
      });
    } catch (_) {
      setState(() => _loadingCurrentPromos = false);
    }
  }

  Future<void> _removeFlashDeal(int dealId) async {
    try {
      HapticFeedback.selectionClick();
      final res = await http.delete(_flashDeleteUri(dealId)).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        _loadCurrentPromotions();
      }
    } catch (_) {}
  }



  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  TextStyle _h1() => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.4,
    color: _ink.withOpacity(0.92),
  );

  TextStyle _subtle() => GoogleFonts.manrope(
    fontSize: 12.6,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: _ink.withOpacity(0.55),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        final t = _ambientCtrl.value;
        final float = sin(t * pi * 2) * 2.5;

        return Column(
          children: [
            _topHeader(float: float),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Today Overview",
                      "Sales, inventory and receivables",
                      Icons.insights_rounded,
                    ),
                    const SizedBox(height: 12),
                    _statsGrid(),

                    const SizedBox(height: 18),
                    _sectionHeader(
                      "Orders",
                      "Processing & delivery progress",
                      Icons.local_shipping_rounded,
                      actionText: "Open Orders",
                      onAction: widget.onOpenOrders,
                    ),
                    const SizedBox(height: 12),
                    _ordersProgressCard(),

                    const SizedBox(height: 18),
                    _sectionHeader(
                      "Promotions",
                      "Boost your shop visibility",
                      Icons.campaign_rounded,
                      actionText: "Create",
                      onAction: () => HapticFeedback.selectionClick(),
                    ),
                    const SizedBox(height: 12),
                    _promoCards(),

                    const SizedBox(height: 18),
                    _sectionHeader(
                      "Quick Actions",
                      "Shortcuts for daily work",
                      Icons.bolt_rounded,
                    ),
                    const SizedBox(height: 12),
                    _quickActions(),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _topHeader({required double float}) {
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
                _primary.withOpacity(0.96),
                _secondary.withOpacity(0.92),
                _primary.withOpacity(0.94),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.1),
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
              Positioned(
                right: -40,
                top: -40 + float,
                child: Container(
                  width: 180,
                  height: 180,
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
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.14),
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
                    ),
                    child: Icon(Icons.store_rounded, color: Colors.white.withOpacity(0.92)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Charcoal Boutique",
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.96),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _open ? "OPEN • Lahore" : "CLOSED • Lahore",
                          style: GoogleFonts.manrope(
                            fontSize: 12.2,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _openToggle(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _openToggle() {
    final chipColor = _open ? const Color(0xFF2FB06B) : const Color(0xFFE04343);
    final r = BorderRadius.circular(999);

    return InkWell(
      borderRadius: r,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _open = !_open);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: r,
          color: Colors.white.withOpacity(0.16),
          border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 20,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: r,
                color: Colors.white.withOpacity(0.16),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: _open ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: r,
                color: chipColor.withOpacity(0.20),
                border: Border.all(color: chipColor.withOpacity(0.25), width: 1.0),
              ),
              child: Text(
                _open ? "OPEN" : "CLOSED",
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: chipColor.withOpacity(0.95),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
      String title,
      String subtitle,
      IconData icon, {
        String? actionText,
        VoidCallback? onAction,
      }) {
    return Row(
      children: [
        _floatingIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _h1()),
              const SizedBox(height: 3),
              Text(subtitle, style: _subtle()),
            ],
          ),
        ),
        if (actionText != null && onAction != null)
          _glassPill(text: actionText, onTap: onAction),
      ],
    );
  }

  Widget _statsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _statCard(
          title: "Total Sales",
          value: "Rs ${_totalSales.toStringAsFixed(0)}",
          icon: Icons.payments_rounded,
          hint: "This month",
        ),
        _statCard(
          title: "Receivable",
          value: "Rs ${_receivable.toStringAsFixed(0)}",
          icon: Icons.account_balance_wallet_rounded,
          hint: "Pending payout",
        ),
        _statCard(
          title: "Inventory Left",
          value: "$_inventoryLeft items",
          icon: Icons.inventory_2_rounded,
          hint: "Low stock alerts",
        ),
        _statCard(
          title: "Delivered",
          value: "$_deliveredToday today",
          icon: Icons.check_circle_rounded,
          hint: "Delivery success",
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required String hint,
  }) {
    final r = BorderRadius.circular(22);

    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: r,
            color: Colors.white.withOpacity(0.72),
            border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withOpacity(0.10),
                    ),
                    child: Icon(icon, color: _primary.withOpacity(0.88), size: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.trending_up_rounded, size: 18, color: _ink.withOpacity(0.35)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: _ink.withOpacity(0.92),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: _subtle()),
              const SizedBox(height: 6),
              Text(
                hint,
                style: GoogleFonts.manrope(
                  fontSize: 11.6,
                  fontWeight: FontWeight.w800,
                  color: _ink.withOpacity(0.42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ordersProgressCard() {
    final r = BorderRadius.circular(24);
    final double deliveredPct =
    (_deliveredToday / max(1, _deliveredToday + _processing))
        .clamp(0.0, 1.0)
        .toDouble();


    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: r,
            color: Colors.white.withOpacity(0.72),
            border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _chip(icon: Icons.hourglass_top_rounded, text: "$_processing processing"),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _chip(icon: Icons.local_shipping_rounded, text: "$_deliveredToday delivered today"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Delivery progress",
                style: GoogleFonts.manrope(
                  fontSize: 13.6,
                  fontWeight: FontWeight.w900,
                  color: _ink.withOpacity(0.86),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 10,
                  color: _primary.withOpacity(0.10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: deliveredPct,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _secondary.withOpacity(0.95),
                              _primary.withOpacity(0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _glassPill(
                text: "Go to Orders",
                onTap: widget.onOpenOrders,
                filled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _promoCards() {
    Widget card({
      required String title,
      required String sub,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      final r = BorderRadius.circular(22);

      return Expanded(
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: r,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: r,
                  color: Colors.white.withOpacity(0.70),
                  border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _secondary.withOpacity(0.95),
                            _primary.withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Icon(icon, color: Colors.white.withOpacity(0.96), size: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 13.4,
                        fontWeight: FontWeight.w900,
                        color: _ink.withOpacity(0.90),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(sub, style: _subtle()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            card(
              title: "Promotions",
              sub: "Create shop promotions & flash deals",
              icon: Icons.campaign_rounded,
              onTap: () async {
                HapticFeedback.selectionClick();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerPromotionsScreen(
                      ownerUserId: widget.ownerUserId,
                      shopId: widget.ownerUserId,
                    ),
                  ),
                );
                _loadCurrentPromotions();
              },
            ),
            const SizedBox(width: 12),
            card(
              title: "Flash Deals",
              sub: "List & remove flash deals",
              icon: Icons.flash_on_rounded,
              onTap: () async {
                HapticFeedback.selectionClick();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerFlashDealsScreen(
                      ownerUserId: widget.ownerUserId,
                      shopId: widget.ownerUserId,
                    ),
                  ),
                );
                _loadCurrentPromotions();
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Current Promotions list
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.72),
                border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Current Promotions", style: _h1()),
                      const Spacer(),
                      _glassPill(text: "Refresh", onTap: _loadCurrentPromotions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Shop promotions + flash deals", style: _subtle()),
                  const SizedBox(height: 12),

                  if (_loadingCurrentPromos)
                    LinearProgressIndicator(
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor: _primary.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(_secondary.withOpacity(0.65)),
                    )
                  else ...[
                    if (_promos.isEmpty && _flashDeals.isEmpty)
                      Text("No active promotions yet.", style: _subtle()),

                    if (_promos.isNotEmpty) ...[
                      Text("Shop Promotions", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      ..._promos.take(3).map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.campaign_rounded, size: 18, color: _secondary.withOpacity(0.85)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Tier ${p["tier"]} • ${p["status"]} • Rs ${p["price_paid"]}",
                                  style: _subtle(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],

                    if (_flashDeals.isNotEmpty) ...[
                      Text("Flash Deals", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      ..._flashDeals.take(3).map((d) {
                        final dealId = int.parse(d["id"].toString());
                        final title = (d["title"] ?? "Product").toString();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(Icons.flash_on_rounded, size: 18, color: const Color(0xFFFFB000).withOpacity(0.9)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$title • 25% OFF",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _subtle(),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _removeFlashDeal(dealId),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFFE04343).withOpacity(0.10),
                                    border: Border.all(color: const Color(0xFFE04343).withOpacity(0.22), width: 1),
                                  ),
                                  child: Icon(Icons.delete_rounded, size: 16, color: const Color(0xFFE04343).withOpacity(0.95)),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ],
                  ]
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _quickActions() {
    final actions = [
      ("Add Inventory", Icons.add_box_rounded),
      ("Create Offer", Icons.local_offer_rounded),
      ("Request Payout", Icons.payments_rounded),
      ("Support", Icons.support_agent_rounded),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((a) {
        final r = BorderRadius.circular(999);
        return InkWell(
          borderRadius: r,
          onTap: () => HapticFeedback.selectionClick(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: r,
              color: Colors.white.withOpacity(0.70),
              border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(a.$2, size: 18, color: _primary.withOpacity(0.86)),
                const SizedBox(width: 8),
                Text(
                  a.$1,
                  style: GoogleFonts.manrope(
                    fontSize: 12.2,
                    fontWeight: FontWeight.w900,
                    color: _ink.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _floatingIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.70),
        border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primary.withOpacity(0.10),
          ),
          child: Icon(icon, size: 18, color: _primary.withOpacity(0.86)),
        ),
      ),
    );
  }

  Widget _chip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.62),
        border: Border.all(color: _primary.withOpacity(0.12), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _ink.withOpacity(0.70)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11.8,
              fontWeight: FontWeight.w900,
              color: _ink.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassPill({
    required String text,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    final r = BorderRadius.circular(999);

    return InkWell(
      borderRadius: r,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: r,
          gradient: filled
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _secondary.withOpacity(0.95),
              _primary.withOpacity(0.95),
            ],
          )
              : null,
          color: filled ? null : Colors.white.withOpacity(0.66),
          border: Border.all(
            color: filled ? Colors.white.withOpacity(0.18) : _primary.withOpacity(0.14),
            width: 1.1,
          ),
          boxShadow: filled
              ? [
            BoxShadow(
              color: _secondary.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            color: filled ? Colors.white.withOpacity(0.95) : _ink.withOpacity(0.80),
          ),
        ),
      ),
    );
  }
}
