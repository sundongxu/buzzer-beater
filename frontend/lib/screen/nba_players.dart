import 'package:flutter/material.dart';
import '../model/nba_team.dart';
import '../model/nba_player.dart';
import '../service/nba_api.dart';

class NBAPlayersScreen extends StatefulWidget {
  final NBATeam team;

  const NBAPlayersScreen({super.key, required this.team});

  @override
  State<NBAPlayersScreen> createState() => _NBAPlayersScreenState();
}

class _NBAPlayersScreenState extends State<NBAPlayersScreen> {
  List<NBAPlayer> _players = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final players = await NBAAPI.getPlayers(teamId: widget.team.id);
      setState(() {
        _players = players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.team.fullNameZh} 球员'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPlayers,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _players.isEmpty
                  ? const Center(child: Text('暂无球员数据'))
                  : ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return _buildPlayerCard(player);
                      },
                    ),
    );
  }

  Widget _buildPlayerCard(NBAPlayer player) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: primaryColor.withOpacity(0.2),
          child: Text(
            player.jerseyNumber ?? '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
        ),
        title: Text(
          player.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('位置: ${_getPositionName(player.position)}'),
            if (player.height != null) Text('身高: ${player.height}'),
            if (player.college != null) Text('大学: ${player.college}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showPlayerDetails(player);
        },
      ),
    );
  }

  String _getPositionName(String position) {
    const positionMap = {
      'G': '后卫',
      'F': '前锋',
      'C': '中锋',
      'G-F': '锋卫',
      'F-C': '前锋-中锋',
      'F-G': '前锋-后卫',
    };
    return positionMap[position] ?? position;
  }

  void _showPlayerDetails(NBAPlayer player) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: Text(
                        player.jerseyNumber ?? '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      player.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.team.fullNameZh,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 基本信息
              _buildInfoSection('基本信息', [
                _buildInfoRow('位置', _getPositionName(player.position)),
                if (player.height != null) _buildInfoRow('身高', player.height!),
                if (player.weight != null) _buildInfoRow('体重', '${player.weight} lbs'),
                if (player.country != null) _buildInfoRow('国籍', player.country!),
              ]),
              const SizedBox(height: 24),
              // 选秀信息
              if (player.draftYear != null)
                _buildInfoSection('选秀信息', [
                  _buildInfoRow('选秀年份', player.draftYear.toString()),
                  if (player.draftRound != null)
                    _buildInfoRow('选秀轮次', '第${player.draftRound}轮'),
                  if (player.draftNumber != null)
                    _buildInfoRow('顺位', '第${player.draftNumber}顺位'),
                ]),
              if (player.draftYear != null) const SizedBox(height: 24),
              // 教育背景
              if (player.college != null)
                _buildInfoSection('教育背景', [
                  _buildInfoRow('大学', player.college!),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

