import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth.dart';

/// 榜单Tab - 球队战绩、球员数据排行
class RankingTab extends StatefulWidget {
  const RankingTab({super.key});

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _selectedConference = 'All';
  String _selectedStat = 'PPG';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 赛区选择
        Row(
          children: [
            const Text(
              '赛区：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'All', label: Text('全部', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'East', label: Text('东部', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'West', label: Text('西部', style: TextStyle(fontSize: 12))),
                ],
                selected: {_selectedConference},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedConference = newSelection.first;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 球队战绩榜
        _buildSectionHeader('🏆 球队战绩榜', primaryColor),
        const SizedBox(height: 12),
        _buildTeamRankings(context),

        const SizedBox(height: 32),

        // 球员数据榜
        _buildSectionHeader('📊 球员数据榜', primaryColor),
        const SizedBox(height: 12),
        _buildStatSelector(primaryColor),
        const SizedBox(height: 16),
        _buildPlayerRankings(context),

        const SizedBox(height: 24),

        // 查看完整榜单按钮
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: primaryColor),
          ),
          child: Text('查看完整榜单 →', style: TextStyle(color: primaryColor)),
        ),
      ],
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

  Widget _buildTeamRankings(BuildContext context) {
    final user = context.watch<Auth>().user;
    if (user == null) return const SizedBox();

    final teams = [
      {'rank': 1, 'name': '湖人', 'win': 50, 'loss': 15, 'winRate': 0.769, 'isMyTeam': true, 'color': user.team.primaryColor},
      {'rank': 2, 'name': '勇士', 'win': 48, 'loss': 17, 'winRate': 0.738, 'isMyTeam': false, 'color': Colors.blue},
      {'rank': 3, 'name': '快船', 'win': 45, 'loss': 20, 'winRate': 0.692, 'isMyTeam': false, 'color': Colors.red},
      {'rank': 4, 'name': '太阳', 'win': 43, 'loss': 22, 'winRate': 0.662, 'isMyTeam': false, 'color': Colors.purple},
      {'rank': 5, 'name': '掘金', 'win': 42, 'loss': 23, 'winRate': 0.646, 'isMyTeam': false, 'color': Colors.orange},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // 表头
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Text('排名', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const Expanded(child: Text('球队', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 60, child: Text('胜-负', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                const SizedBox(width: 60, child: Text('胜率', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                const SizedBox(width: 60, child: Text('近况', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // 列表
          ...teams.map((team) => _buildTeamRankItem(team, user.team.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildTeamRankItem(Map<String, dynamic> team, Color myTeamColor) {
    final isMyTeam = team['isMyTeam'] as bool;
    final rank = team['rank'] as int;
    
    return Container(
      decoration: BoxDecoration(
        color: isMyTeam ? myTeamColor.withOpacity(0.1) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 40,
            child: Row(
              children: [
                if (rank <= 3)
                  Text(
                    ['🥇', '🥈', '🥉'][rank - 1],
                    style: const TextStyle(fontSize: 16),
                  )
                else
                  Text(
                    rank.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          // 球队
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: team['color'] as Color,
                  ),
                  child: Center(
                    child: Text(
                      team['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  team['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isMyTeam ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isMyTeam) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: myTeamColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '主队',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 胜负
          SizedBox(
            width: 60,
            child: Text(
              '${team['win']}-${team['loss']}',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          // 胜率
          SizedBox(
            width: 60,
            child: Text(
              team['winRate'].toStringAsFixed(3),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          // 近况
          SizedBox(
            width: 60,
            child: Text(
              '↑↑↑↑↑',
              style: TextStyle(fontSize: 12, color: Colors.green[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSelector(Color primaryColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatChip('PPG', '得分', primaryColor),
          _buildStatChip('APG', '助攻', primaryColor),
          _buildStatChip('RPG', '篮板', primaryColor),
          _buildStatChip('SPG', '抢断', primaryColor),
          _buildStatChip('BPG', '盖帽', primaryColor),
          _buildStatChip('3PM', '三分', primaryColor),
          _buildStatChip('EFF', '效率', primaryColor),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color primaryColor) {
    final isSelected = _selectedStat == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStat = value;
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

  Widget _buildPlayerRankings(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    final players = [
      {'rank': 1, 'name': '詹姆斯', 'team': '湖人', 'stat': 29.8, 'trend': '📈 +2.3'},
      {'rank': 2, 'name': '杜兰特', 'team': '太阳', 'stat': 28.5, 'trend': '📈 +1.8'},
      {'rank': 3, 'name': '字母哥', 'team': '雄鹿', 'stat': 27.2, 'trend': '📉 -0.5'},
      {'rank': 4, 'name': '东契奇', 'team': '独行侠', 'stat': 26.8, 'trend': '📈 +1.2'},
      {'rank': 5, 'name': '恩比德', 'team': '76人', 'stat': 26.5, 'trend': '📈 +0.8'},
    ];

    return Column(
      children: players.map((player) {
        final rank = player['rank'] as int;
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 排名
                SizedBox(
                  width: 40,
                  child: Text(
                    rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : rank.toString(),
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                // 头像
                CircleAvatar(
                  radius: 25,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Text(
                    player['name'].toString().substring(0, 1),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 球员信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            player['team'] as String,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            player['trend'] as String,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 数据
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      player['stat'].toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      _selectedStat,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

