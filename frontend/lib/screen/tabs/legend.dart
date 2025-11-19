import 'package:flutter/material.dart';

/// 传奇Tab - 名人堂、经典时刻、历史记录
class LegendTab extends StatefulWidget {
  const LegendTab({super.key});

  @override
  State<LegendTab> createState() => _LegendTabState();
}

class _LegendTabState extends State<LegendTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _selectedCategory = 'Hall';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 分类选择
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('Hall', '名人堂', primaryColor),
              _buildCategoryChip('Moment', '经典时刻', primaryColor),
              _buildCategoryChip('Record', '历史记录', primaryColor),
              _buildCategoryChip('Dynasty', '王朝球队', primaryColor),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 根据选择显示不同内容
        if (_selectedCategory == 'Hall') ...[
          _buildSectionHeader('🏆 名人堂传奇', primaryColor),
          const SizedBox(height: 12),
          _buildHallOfFame(context),
        ] else if (_selectedCategory == 'Moment') ...[
          _buildSectionHeader('⚡ 经典时刻', primaryColor),
          const SizedBox(height: 12),
          _buildClassicMoments(context),
        ] else if (_selectedCategory == 'Record') ...[
          _buildSectionHeader('📊 历史记录', primaryColor),
          const SizedBox(height: 12),
          _buildHistoricalRecords(context),
        ] else if (_selectedCategory == 'Dynasty') ...[
          _buildSectionHeader('👑 王朝球队', primaryColor),
          const SizedBox(height: 12),
          _buildDynastyTeams(context),
        ],
      ],
    );
  }

  Widget _buildCategoryChip(String value, String label, Color primaryColor) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHallOfFame(BuildContext context) {
    final legends = [
      {
        'name': '迈克尔·乔丹',
        'team': '公牛',
        'years': '1984-2003',
        'achievements': '6次总冠军 · 5次MVP · 10次得分王',
        'number': '23',
        'color': Colors.red,
      },
      {
        'name': '科比·布莱恩特',
        'team': '湖人',
        'years': '1996-2016',
        'achievements': '5次总冠军 · MVP · 18次全明星',
        'number': '24',
        'color': Colors.purple,
      },
      {
        'name': '勒布朗·詹姆斯',
        'team': '骑士/热火/湖人',
        'years': '2003-至今',
        'achievements': '4次总冠军 · 4次MVP · 历史得分王',
        'number': '23',
        'color': Colors.orange,
      },
      {
        'name': '魔术师约翰逊',
        'team': '湖人',
        'years': '1979-1996',
        'achievements': '5次总冠军 · 3次MVP · 史上最佳控卫',
        'number': '32',
        'color': Colors.purple,
      },
      {
        'name': '拉里·伯德',
        'team': '凯尔特人',
        'years': '1979-1992',
        'achievements': '3次总冠军 · 3次MVP · 2次FMVP',
        'number': '33',
        'color': Colors.green,
      },
    ];

    return Column(
      children: legends.map((legend) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (legend['color'] as Color).withOpacity(0.1),
                (legend['color'] as Color).withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: (legend['color'] as Color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 球衣号码
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: legend['color'] as Color,
                    boxShadow: [
                      BoxShadow(
                        color: (legend['color'] as Color).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      legend['number'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 球员信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            legend['name'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '👑 传奇',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.sports_basketball,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${legend['team']} · ${legend['years']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        legend['achievements'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassicMoments(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    final moments = [
      {
        'title': '乔丹最后一投',
        'description': '1998年总决赛G6，乔丹关键一投绝杀爵士，完成两连冠',
        'date': '1998.6.14',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
      },
      {
        'title': '科比81分之夜',
        'description': '单场砍下81分，历史第二高分，湖人逆转猛龙',
        'date': '2006.1.22',
        'icon': Icons.whatshot,
        'color': Colors.purple,
      },
      {
        'title': '雷阿伦救命三分',
        'description': '总决赛G6关键三分，热火续命并最终夺冠',
        'date': '2013.6.18',
        'icon': Icons.gps_fixed,
        'color': Colors.orange,
      },
      {
        'title': '麦迪35秒13分',
        'description': '奇迹般的大逆转，35秒狂砍13分击败马刺',
        'date': '2004.12.9',
        'icon': Icons.flash_on,
        'color': Colors.blue,
      },
      {
        'title': '詹姆斯追身大帽',
        'description': '2016总决赛G7，詹姆斯关键时刻封盖伊戈达拉',
        'date': '2016.6.19',
        'icon': Icons.block,
        'color': Colors.deepOrange,
      },
    ];

    return Column(
      children: moments.map((moment) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('查看 ${moment['title']}')),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 图标
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          moment['color'] as Color,
                          (moment['color'] as Color).withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Icon(
                      moment['icon'] as IconData,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moment['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          moment['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              moment['date'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.play_circle_outline,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '观看视频',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoricalRecords(BuildContext context) {
    final records = [
      {'title': '单场最高分', 'holder': '威尔特·张伯伦', 'value': '100分', 'date': '1962.3.2'},
      {'title': '生涯总得分', 'holder': '勒布朗·詹姆斯', 'value': '40,474分', 'date': '至今'},
      {'title': '单赛季场均得分', 'holder': '威尔特·张伯伦', 'value': '50.4分', 'date': '1961-62'},
      {'title': '生涯总助攻', 'holder': '约翰·斯托克顿', 'value': '15,806次', 'date': '1984-2003'},
      {'title': '单场助攻纪录', 'holder': '斯科特·斯基尔斯', 'value': '30次', 'date': '1990.12.30'},
      {'title': '单赛季三分球', 'holder': '斯蒂芬·库里', 'value': '402个', 'date': '2015-16'},
      {'title': '生涯总篮板', 'holder': '威尔特·张伯伦', 'value': '23,924个', 'date': '1959-73'},
      {'title': '单场篮板纪录', 'holder': '威尔特·张伯伦', 'value': '55个', 'date': '1960.11.24'},
    ];

    return Column(
      children: records.map((record) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber,
                    Colors.amber.shade700,
                  ],
                ),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 26,
              ),
            ),
            title: Text(
              record['title']!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  record['holder']!,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  record['date']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record['value']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDynastyTeams(BuildContext context) {
    final dynasties = [
      {
        'team': '芝加哥公牛',
        'era': '1991-1998',
        'championships': '6',
        'leader': '迈克尔·乔丹',
        'description': '乔丹带领公牛完成两次三连冠，缔造90年代最强王朝',
        'color': Colors.red,
      },
      {
        'team': '洛杉矶湖人',
        'era': '2000-2002',
        'championships': '3',
        'leader': '奥尼尔 & 科比',
        'description': 'OK组合统治联盟，完成三连冠霸业',
        'color': Colors.purple,
      },
      {
        'team': '金州勇士',
        'era': '2015-2018',
        'championships': '3',
        'leader': '斯蒂芬·库里',
        'description': '勇士开创小球时代，4年3冠统治力惊人',
        'color': Colors.blue,
      },
      {
        'team': '波士顿凯尔特人',
        'era': '1957-1969',
        'championships': '11',
        'leader': '比尔·拉塞尔',
        'description': '绿军创造8连冠神迹，13年11冠前无古人',
        'color': Colors.green,
      },
      {
        'team': '圣安东尼奥马刺',
        'era': '1999-2014',
        'championships': '5',
        'leader': '蒂姆·邓肯',
        'description': '马刺15年5冠，邓肯带队成就最稳定王朝',
        'color': Colors.grey[800]!,
      },
    ];

    return Column(
      children: dynasties.map((dynasty) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (dynasty['color'] as Color).withOpacity(0.15),
                (dynasty['color'] as Color).withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: (dynasty['color'] as Color).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dynasty['color'] as Color,
                        boxShadow: [
                          BoxShadow(
                            color: (dynasty['color'] as Color).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '👑',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dynasty['team'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dynasty['era']} · ${dynasty['championships']}冠',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '核心球员：${dynasty['leader']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dynasty['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

