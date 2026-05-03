import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:balanceballers/views/attendance/attendance_screen.dart';
import 'package:balanceballers/views/debtors/debtors_screen.dart';
import 'package:balanceballers/views/free_players/free_player_screen.dart';
import 'package:balanceballers/views/players/player_list_screen.dart';
import 'package:balanceballers/views/register/register_screen.dart';
import 'package:balanceballers/views/attendance/attendance_list_screen.dart';
import 'package:balanceballers/widgets/app_mesh_background.dart';
import 'package:balanceballers/widgets/bento_menu_item.dart';

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
          AppMeshBackground(isDark: _isDark),
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
          icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode,
              color: textColor),
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
      {
        "title": "ثبت نام",
        "icon": Icons.person_add_alt_1,
        "color": Colors.blueAccent,
        "page": const Register()
      },
      {
        "title": "بازیکنان",
        "icon": Icons.groups_sharp,
        "color": Colors.orangeAccent,
        "page": PlayerList()
      },
      {
        "title": "قرض دارها",
        "icon": Icons.account_balance_wallet,
        "color": Colors.redAccent,
        "page": Debtors()
      },
      {
        "title": "حاضری",
        "icon": Icons.how_to_reg,
        "color": Colors.tealAccent,
        "page": const Attendance()
      },
      {
        "title": "لیست حاضری",
        "icon": Icons.view_list,
        "color": Colors.purpleAccent,
        "page": AttendanceList()
      },
      {
        "title": "ثبت رایگان",
        "icon": Icons.card_giftcard,
        "color": Colors.pinkAccent,
        "page": const FreePlayer()
      },
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
                  curve: Interval((index / menuItems.length) * 0.5, 1.0,
                      curve: Curves.easeOutCubic),
                );
                return Opacity(
                  opacity: animation.value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - animation.value)),
                    child: BentoMenuItem(
                      title: menuItems[index]['title'] as String,
                      icon: menuItems[index]['icon'] as IconData,
                      color: menuItems[index]['color'] as Color,
                      page: menuItems[index]['page'] as Widget,
                      isDark: isDark,
                      textColor: textColor,
                    ),
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
