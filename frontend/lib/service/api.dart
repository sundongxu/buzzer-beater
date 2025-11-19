import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../config/constants.dart';

class API {
  static final dio = Dio(BaseOptions(
    baseUrl: APIConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 设置 Token
  static void setToken(String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  // 注册用户
  static Future<Map<String, dynamic>> createUser({
    required String nickname,
    required String password,
    required XFile avatar,
    required int teamId,
  }) async {
    // 读取文件字节（兼容 Web 和移动端）
    final bytes = await avatar.readAsBytes();
    final filename = avatar.name;

    final formData = FormData.fromMap({
      'nickname': nickname,
      'password': password,
      'team_id': teamId,
      'avatar': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });

    final res = await dio.post('/users', data: formData);
    return res.data as Map<String, dynamic>;
  }

  // 登录（创建会话）
  static Future<Map<String, dynamic>> createSession({
    required String nickname,
    required String password,
  }) async {
    final res = await dio.post('/session', data: {
      'nickname': nickname,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  // 注销（删除会话）
  static Future<void> deleteSession() async {
    await dio.delete('/session');
  }

  // 获取当前用户
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await dio.get('/users/me');
    return res.data as Map<String, dynamic>;
  }

  // 更新头像
  static Future<Map<String, dynamic>> updateAvatar(XFile avatar) async {
    // 读取文件字节（兼容 Web 和移动端）
    final bytes = await avatar.readAsBytes();
    final filename = avatar.name;

    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });

    final res = await dio.put('/users/me/avatar', data: formData);
    return res.data as Map<String, dynamic>;
  }

  // 更新主队
  static Future<Map<String, dynamic>> updateTeam(int teamId) async {
    final res = await dio.put('/users/me/team', data: {
      'team_id': teamId,
    });
    return res.data as Map<String, dynamic>;
  }

  // 获取球队列表
  static Future<List<dynamic>> getTeams() async {
    final res = await dio.get('/teams');
    return res.data as List<dynamic>;
  }

  // 获取完整的图片URL
  static String getImageUrl(String path) {
    return '${APIConfig.uploadsBaseUrl}$path';
  }
}
