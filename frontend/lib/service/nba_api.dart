import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../model/nba_team.dart';
import '../model/nba_player.dart';

class NBAAPI {
  static final dio = Dio(BaseOptions(
    baseUrl: APIConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // 获取 NBA 球队列表
  static Future<List<NBATeam>> getTeams() async {
    try {
      final res = await dio.get('/nba/teams');
      final List data = res.data as List;
      return data.map((json) => NBATeam.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取球队列表失败: $e');
    }
  }

  // 获取 NBA 球员列表
  static Future<List<NBAPlayer>> getPlayers({int? teamId}) async {
    try {
      final queryParams = teamId != null ? {'team_id': teamId} : null;
      final res = await dio.get('/nba/players', queryParameters: queryParams);
      final List data = res.data as List;
      return data.map((json) => NBAPlayer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取球员列表失败: $e');
    }
  }

  // 获取球员统计数据（需要登录）
  static Future<Map<String, dynamic>> getPlayerStats(int playerId, {int season = 2024}) async {
    try {
      final res = await dio.get(
        '/nba/players/$playerId/stats',
        queryParameters: {'season': season},
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取球员统计失败: $e');
    }
  }
}

