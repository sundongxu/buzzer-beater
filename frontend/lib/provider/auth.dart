import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user.dart';
import '../service/api.dart';
import '../service/storage.dart';

class Auth with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = true;

  bool get isAuth => _token != null && _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;

  // 动态主题
  ThemeData get theme {
    if (_user != null) {
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _user!.team.primaryColor,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: _user!.team.primaryColor,
          foregroundColor: Colors.white,
        ),
      );
    }

    // 默认主题（未登录时）
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      useMaterial3: true,
    );
  }

  // 初始化（从本地加载 Token）
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await Storage.getToken();
      if (token != null) {
        _token = token;
        API.setToken(token);
        await _loadUser();
      }
    } catch (e) {
      // 加载失败，清除 Token
      await Storage.clearToken();
      _token = null;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 加载用户信息
  Future<void> _loadUser() async {
    try {
      final data = await API.getCurrentUser();
      _user = User.fromJson(data);
    } catch (e) {
      _token = null;
      _user = null;
      await Storage.clearToken();
      rethrow;
    }
  }

  // 注册
  Future<void> register({
    required String nickname,
    required String password,
    required XFile avatar,
    required int teamId,
  }) async {
    final data = await API.createUser(
      nickname: nickname,
      password: password,
      avatar: avatar,
      teamId: teamId,
    );

    _token = data['token'] as String;
    _user = User.fromJson(data);

    await Storage.saveToken(_token!);
    API.setToken(_token);

    notifyListeners();
  }

  // 登录
  Future<void> login({
    required String nickname,
    required String password,
  }) async {
    final data = await API.createSession(
      nickname: nickname,
      password: password,
    );

    _token = data['token'] as String;
    _user = User.fromJson(data['user'] as Map<String, dynamic>);

    await Storage.saveToken(_token!);
    API.setToken(_token);

    notifyListeners();
  }

  // 注销
  Future<void> logout() async {
    try {
      await API.deleteSession();
    } catch (e) {
      // 忽略网络错误，继续注销
    }

    _token = null;
    _user = null;
    API.setToken(null);
    await Storage.clearToken();

    notifyListeners();
  }
}

