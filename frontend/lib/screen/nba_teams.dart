import 'package:flutter/material.dart';
import '../model/nba_team.dart';
import '../service/nba_api.dart';
import 'nba_players.dart';

class NBATeamsScreen extends StatefulWidget {
  const NBATeamsScreen({super.key});

  @override
  State<NBATeamsScreen> createState() => _NBATeamsScreenState();
}

class _NBATeamsScreenState extends State<NBATeamsScreen> {
  List<NBATeam> _teams = [];
  List<NBATeam> _filteredTeams = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedConference = 'All';

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final teams = await NBAAPI.getTeams();
      setState(() {
        _teams = teams;
        _filterTeams();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTeams() {
    if (_selectedConference == 'All') {
      _filteredTeams = _teams;
    } else {
      _filteredTeams = _teams
          .where((team) => team.conference == _selectedConference)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NBA 球队'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTeams,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 分区筛选器
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('分区：',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'All', label: Text('全部')),
                                ButtonSegment(value: 'East', label: Text('东部')),
                                ButtonSegment(value: 'West', label: Text('西部')),
                              ],
                              selected: {_selectedConference},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _selectedConference = newSelection.first;
                                  _filterTeams();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // 球队列表
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredTeams.length,
                        itemBuilder: (context, index) {
                          final team = _filteredTeams[index];
                          return _buildTeamCard(team);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTeamCard(NBATeam team) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: team.logoUrl.isNotEmpty
              ? Image.network(
                  team.logoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        team.abbreviation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    team.abbreviation,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        title: Text(
          team.fullNameZh,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                '${_getConferenceZh(team.conference)} · ${_getDivisionZh(team.division)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NBAPlayersScreen(team: team),
            ),
          );
        },
      ),
    );
  }

  String _getConferenceZh(String conference) {
    return conference == 'East' ? '东部' : '西部';
  }

  String _getDivisionZh(String division) {
    const divisionMap = {
      'Atlantic': '大西洋赛区',
      'Central': '中部赛区',
      'Southeast': '东南赛区',
      'Northwest': '西北赛区',
      'Pacific': '太平洋赛区',
      'Southwest': '西南赛区',
    };
    return divisionMap[division] ?? division;
  }
}
