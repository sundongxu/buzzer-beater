import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth.dart';
import '../service/api.dart';
import 'profile.dart';
import 'tabs/feed.dart';
import 'tabs/ranking.dart';
import 'tabs/legend.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<Auth>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final primaryColor = user.team.primaryColor;
    final accentColor = user.team.accentColor;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 简洁AppBar
            SliverAppBar(
              expandedHeight: 70,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, accentColor],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // BuzzerBeater Logo - 扁平化篮板
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: _BuzzerBeatLogo(primaryColor),
                            ),
                          ),
                          const Spacer(),
                          // 用户头像 - 点击进入个人中心
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  API.getImageUrl(user.avatar),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Tab导航栏
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                primaryColor,
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: [
                    Tab(
                      icon: _AnimatedTabIcon(
                        icon: Icons.whatshot,
                        isSelected: _currentTabIndex == 0,
                        color: primaryColor,
                      ),
                      text: '动态',
                    ),
                    Tab(
                      icon: _AnimatedTabIcon(
                        icon: Icons.leaderboard,
                        isSelected: _currentTabIndex == 1,
                        color: primaryColor,
                      ),
                      text: '榜单',
                    ),
                    Tab(
                      icon: _AnimatedTabIcon(
                        icon: Icons.stars,
                        isSelected: _currentTabIndex == 2,
                        color: primaryColor,
                      ),
                      text: '传奇',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            FeedTab(),
            RankingTab(),
            LegendTab(),
          ],
        ),
      ),
    );
  }
}

// TabBar固定delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.primaryColor, this.tabBar);

  final Color primaryColor;
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        primaryColor != oldDelegate.primaryColor;
  }
}

// 带动画效果的 Tab Icon
class _AnimatedTabIcon extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;

  const _AnimatedTabIcon({
    required this.icon,
    required this.isSelected,
    required this.color,
  });

  @override
  State<_AnimatedTabIcon> createState() => _AnimatedTabIconState();
}

class _AnimatedTabIconState extends State<_AnimatedTabIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: widget.isSelected
                  ? BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                widget.icon,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

// App Icon 扁平化Logo - 极简风格
class _BuzzerBeatLogo extends CustomPainter {
  final Color teamColor;

  _BuzzerBeatLogo(this.teamColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. 计时器 - 极简黑色矩形
    final timerBgPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final timerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.32,
        size.height * 0.08,
        size.width * 0.36,
        size.height * 0.09,
      ),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(timerRect, timerBgPaint);

    // 计时器显示 "0:0"
    final timerText = TextPainter(
      text: const TextSpan(
        text: '0:0',
        style: TextStyle(
          color: Color(0xFFFF0000),
          fontSize: 5.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timerText.layout();
    timerText.paint(
      canvas,
      Offset(
        center.dx - timerText.width / 2,
        size.height * 0.092,
      ),
    );

    // 2. 篮板 - 纯白色填充矩形
    final backboardFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final backboardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.24,
        size.width * 0.76,
        size.height * 0.28,
      ),
      const Radius.circular(1),
    );
    canvas.drawRRect(backboardRect, backboardFillPaint);

    // 篮板边框
    final backboardBorderPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(backboardRect, backboardBorderPaint);

    // 篮板小框（简化）
    final innerBoxPaint = Paint()
      ..color = const Color(0xFF7F8C8D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.30,
          size.height * 0.35,
          size.width * 0.40,
          size.height * 0.14,
        ),
        const Radius.circular(0.8),
      ),
      innerBoxPaint,
    );

    // 3. 篮筐 - 红色实心椭圆
    final rimPaint = Paint()
      ..color = const Color(0xFFE74C3C)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.58),
        width: size.width * 0.35,
        height: size.height * 0.07,
      ),
      rimPaint,
    );

    // 篮筐深色边框
    final rimBorderPaint = Paint()
      ..color = const Color(0xFFC0392B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.58),
        width: size.width * 0.35,
        height: size.height * 0.07,
      ),
      rimBorderPaint,
    );

    // 4. 球网 - 极简三角形
    final netPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final netPath = Path();
    netPath.moveTo(center.dx - size.width * 0.175, size.height * 0.58);
    netPath.lineTo(center.dx + size.width * 0.175, size.height * 0.58);
    netPath.lineTo(center.dx, size.height * 0.68);
    netPath.close();
    canvas.drawPath(netPath, netPaint);

    // 球网边框
    final netBorderPaint = Paint()
      ..color = const Color(0xFFBDC3C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(netPath, netBorderPaint);

    // 简化网格（2条横线）
    final netLinePaint = Paint()
      ..color = const Color(0xFFECF0F1)
      ..strokeWidth = 1;

    for (int i = 1; i <= 2; i++) {
      final y = size.height * 0.58 + (size.height * 0.10 * i / 3);
      final xOffset = size.width * 0.175 * (1 - i / 3);
      canvas.drawLine(
        Offset(center.dx - xOffset, y),
        Offset(center.dx + xOffset, y),
        netLinePaint,
      );
    }

    // 5. 篮球 - 扁平圆形
    final ballCenter = Offset(center.dx, size.height * 0.82);
    final ballRadius = size.width * 0.15;

    // 篮球主体
    final ballPaint = Paint()
      ..color = teamColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(ballCenter, ballRadius, ballPaint);

    // 篮球纹理（极简2条线）
    final ballLinePaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // 竖线
    canvas.drawLine(
      Offset(ballCenter.dx, ballCenter.dy - ballRadius * 0.75),
      Offset(ballCenter.dx, ballCenter.dy + ballRadius * 0.75),
      ballLinePaint,
    );

    // 单条弧线
    canvas.drawArc(
      Rect.fromCircle(center: ballCenter, radius: ballRadius * 0.55),
      -2.6,
      2.0,
      false,
      ballLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
