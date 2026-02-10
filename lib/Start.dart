import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Your existing imports
import 'package:balanceballers/Attendance.dart';
import 'package:balanceballers/Debtors.dart';
import 'package:balanceballers/Free_Player.dart';
import 'package:balanceballers/Players.dart';
import 'package:balanceballers/Register.dart';
import 'package:balanceballers/ShowFreePalyer.dart';
import 'package:balanceballers/showAttendance.dart';

class Start extends StatefulWidget {
  final Function toggleTheme;
  const Start({super.key, required this.toggleTheme});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> with SingleTickerProviderStateMixin {
  bool _isDark = false;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = _isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _buildMeshBackground(_isDark),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(textColor),
                _buildHeader(textColor),
                _buildBentoGrid(_isDark, textColor),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBackground(bool isDark) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1E293B), const Color(0xFF020617), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Color textColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 'logo-ball',
          child: Image.asset("assets/pic/football.png"),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _isDark = !_isDark);
            widget.toggleTheme();
          },
          icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode, color: textColor),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildHeader(Color textColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Text(
              "MOTTAHED",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: textColor,
                fontFamily: "ProtestGuerrilla",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "FUTSAL ACADEMY",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 4,
                color: textColor.withValues(alpha: .6),
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 25),
            Image.asset("assets/pic/logo.png", height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(bool isDark, Color textColor) {
    final List<Map<String, dynamic>> menuItems = [
      {"title": "ثبت نام", "icon": Icons.person_add_alt_1, "color": Colors.blueAccent, "page": const Register()},
      {"title": "بازیکنان", "icon": Icons.groups_sharp, "color": Colors.orangeAccent, "page": PlayerList()},
      {"title": "قرض دارها", "icon": Icons.account_balance_wallet, "color": Colors.redAccent, "page": Debtors()},
      {"title": "حاضری", "icon": Icons.how_to_reg, "color": Colors.tealAccent, "page": const Attendance()},
      {"title": "لیست حاضری", "icon": Icons.view_list, "color": Colors.purpleAccent, "page": AttendanceList()},
      {"title": "ثبت رایگان", "icon": Icons.card_giftcard, "color": Colors.pinkAccent, "page": const FreePlayer()},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 1.05,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimatedBuilder(
              animation: _listController,
              builder: (context, child) {
                final animation = CurvedAnimation(
                  parent: _listController,
                  curve: Interval((index / menuItems.length) * 0.5, 1.0, curve: Curves.easeOutCubic),
                );
                return Opacity(
                  opacity: animation.value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - animation.value)),
                    child: _BentoItem(item: menuItems[index], isDark: isDark, textColor: textColor),
                  ),
                );
              },
            );
          },
          childCount: menuItems.length,
        ),
      ),
    );
  }
}

class _BentoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final Color textColor;

  const _BentoItem({required this.item, required this.isDark, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 200),
      openColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      openBuilder: (context, _) => item['page'] as Widget,
      closedBuilder: (context, openContainer) => InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          openContainer();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: .06) : Colors.black.withValues(alpha: .03),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: textColor.withValues(alpha: .1), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
