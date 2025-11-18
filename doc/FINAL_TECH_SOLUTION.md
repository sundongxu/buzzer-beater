# 🏀 BuzzerBeater 最终技术方案

## Flutter + Go 全栈开发指南

---

## 一、技术栈确认

### 完整架构

```
┌─────────────────────────────────────────┐
│           前端 (Flutter)                │
├─────────────────────────────────────────┤
│  Dart 3.2+                              │
│  Flutter 3.16+                          │
│  Material Design 3                      │
│  Provider (状态管理)                     │
│  Dio (网络请求)                          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           后端 (Go)                     │
├─────────────────────────────────────────┤
│  Go 1.21+                               │
│  Gin (Web框架)                          │
│  GORM (ORM)                             │
│  JWT (认证)                             │
│  Cron (定时任务)                         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           数据层                         │
├─────────────────────────────────────────┤
│  PostgreSQL 15+                         │
│  Redis 7+                               │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           部署                           │
├─────────────────────────────────────────┤
│  前端: 编译到各平台                      │
│  后端: Fly.io / Railway                 │
│  数据库: 托管服务                        │
└─────────────────────────────────────────┘
```

---

## 二、前端 Flutter 完整方案

### 2.1 项目创建

```bash
# 1. 安装 Flutter（如果还没安装）
# macOS:
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip -o flutter.zip
unzip flutter.zip
export PATH="$PATH:`pwd`/flutter/bin"

# 验证安装
flutter doctor

# 2. 创建项目
flutter create buzzerbeater
cd buzzerbeater

# 3. 运行测试
flutter run
```

### 2.2 完整项目结构

```
buzzerbeater/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── app.dart                       # App 配置
│   │
│   ├── config/                        # 配置
│   │   ├── api_config.dart           # API 配置
│   │   ├── theme_config.dart         # 主题配置
│   │   └── constants.dart            # 常量
│   │
│   ├── models/                        # 数据模型
│   │   ├── user.dart
│   │   ├── team.dart
│   │   ├── player.dart
│   │   ├── game.dart
│   │   └── game_stats.dart
│   │
│   ├── services/                      # 服务层
│   │   ├── api_service.dart          # API 调用
│   │   ├── auth_service.dart         # 认证服务
│   │   ├── storage_service.dart      # 本地存储
│   │   └── websocket_service.dart    # WebSocket
│   │
│   ├── providers/                     # 状态管理
│   │   ├── auth_provider.dart
│   │   ├── games_provider.dart
│   │   ├── teams_provider.dart
│   │   ├── players_provider.dart
│   │   └── favorites_provider.dart
│   │
│   ├── screens/                       # 页面
│   │   ├── onboarding/               # 首次引导
│   │   │   ├── welcome_screen.dart
│   │   │   ├── select_teams_screen.dart
│   │   │   └── select_players_screen.dart
│   │   ├── home/                     # 首页
│   │   │   └── home_screen.dart
│   │   ├── games/                    # 比赛
│   │   │   ├── games_screen.dart
│   │   │   └── game_detail_screen.dart
│   │   ├── teams/                    # 球队
│   │   │   ├── teams_screen.dart
│   │   │   └── team_detail_screen.dart
│   │   ├── players/                  # 球员
│   │   │   ├── players_screen.dart
│   │   │   └── player_detail_screen.dart
│   │   └── profile/                  # 个人
│   │       ├── profile_screen.dart
│   │       └── settings_screen.dart
│   │
│   ├── widgets/                       # 可复用组件
│   │   ├── game_card.dart
│   │   ├── team_card.dart
│   │   ├── player_card.dart
│   │   ├── live_score_widget.dart
│   │   ├── stat_chart_widget.dart
│   │   └── common/
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       └── empty_state_widget.dart
│   │
│   └── utils/                         # 工具类
│       ├── date_formatter.dart
│       ├── validators.dart
│       └── extensions.dart
│
├── assets/                            # 资源文件
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/                              # 测试
├── pubspec.yaml                       # 依赖配置
└── README.md
```

### 2.3 依赖配置 (pubspec.yaml)

```yaml
name: buzzerbeater
description: 新一代篮球社交APP
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  provider: ^6.1.1
  
  # 网络请求
  dio: ^5.4.0
  http: ^1.1.2
  
  # WebSocket
  web_socket_channel: ^2.4.0
  
  # 本地存储
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # 安全存储
  flutter_secure_storage: ^9.0.0
  
  # 路由导航
  go_router: ^13.0.0
  
  # 图表
  fl_chart: ^0.66.0
  
  # 图片
  cached_network_image: ^3.3.1
  
  # 时间处理
  intl: ^0.18.1
  
  # 推送通知
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  
  # UI 工具
  shimmer: ^3.0.0  # 骨架屏
  pull_to_refresh: ^2.0.0
  
  # 其他
  url_launcher: ^6.2.4
  share_plus: ^7.2.1
  package_info_plus: ^5.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

### 2.4 核心代码示例

#### main.dart（应用入口）

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/games_provider.dart';
import 'providers/teams_provider.dart';
import 'providers/players_provider.dart';
import 'providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GamesProvider()),
        ChangeNotifierProvider(create: (_) => TeamsProvider()),
        ChangeNotifierProvider(create: (_) => PlayersProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const BuzzerBeatApp(),
    ),
  );
}
```

#### app.dart（App配置）

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/auth_provider.dart';

class BuzzerBeatApp extends StatelessWidget {
  const BuzzerBeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuzzerBeater',
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      
      // 首页路由
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 根据认证状态显示不同页面
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (!auth.isAuthenticated) {
            return const WelcomeScreen();
          }
          
          if (!auth.hasCompletedOnboarding) {
            return const WelcomeScreen();
          }
          
          return const HomeScreen();
        },
      ),
    );
  }
}
```

#### config/theme_config.dart（主题配置）

```dart
import 'package:flutter/material.dart';

class ThemeConfig {
  // 主色
  static const Color primaryColor = Color(0xFFFF5722); // 橙红色
  static const Color secondaryColor = Color(0xFF1976D2); // 蓝色
  
  // 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    
    // App Bar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    
    // Card
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // 输入框
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    ),
    
    // 按钮
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
  
  // 深色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  // 球队主题色配置
  static Color getTeamColor(String teamCode) {
    final teamColors = {
      'LAL': const Color(0xFF552583), // 湖人紫色
      'GSW': const Color(0xFF1D428A), // 勇士蓝色
      'BOS': const Color(0xFF007A33), // 凯尔特人绿色
      // ... 其他球队
    };
    return teamColors[teamCode] ?? primaryColor;
  }
}
```

#### models/game.dart（数据模型）

```dart
class Game {
  final int id;
  final int homeTeamId;
  final int awayTeamId;
  final int homeScore;
  final int awayScore;
  final String status;
  final int? quarter;
  final String? timeRemaining;
  final DateTime gameDate;
  final Team? homeTeam;
  final Team? awayTeam;

  const Game({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    this.quarter,
    this.timeRemaining,
    required this.gameDate,
    this.homeTeam,
    this.awayTeam,
  });

  bool get isLive => status == 'LIVE';
  bool get isFinished => status == 'FINISHED';

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      homeTeamId: json['home_team_id'],
      awayTeamId: json['away_team_id'],
      homeScore: json['home_score'] ?? 0,
      awayScore: json['away_score'] ?? 0,
      status: json['status'],
      quarter: json['quarter'],
      timeRemaining: json['time_remaining'],
      gameDate: DateTime.parse(json['game_date']),
      homeTeam: json['home_team'] != null 
          ? Team.fromJson(json['home_team']) 
          : null,
      awayTeam: json['away_team'] != null 
          ? Team.fromJson(json['away_team']) 
          : null,
    );
  }

  Game copyWith({
    int? homeScore,
    int? awayScore,
    String? status,
    int? quarter,
    String? timeRemaining,
  }) {
    return Game(
      id: id,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      quarter: quarter ?? this.quarter,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      gameDate: gameDate,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
    );
  }
}

class Team {
  final int id;
  final String name;
  final String code;
  final String logoUrl;
  final String city;

  const Team({
    required this.id,
    required this.name,
    required this.code,
    required this.logoUrl,
    required this.city,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      logoUrl: json['logo_url'],
      city: json['city'],
    );
  }
}
```

#### services/api_service.dart（API服务）

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/game.dart';

class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // 添加拦截器（日志、认证等）
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证 token
        final token = ApiConfig.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 统一错误处理
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }
  
  // 获取今日比赛
  Future<List<Game>> getTodayGames() async {
    try {
      final response = await _dio.get('/games/today');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Game.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取比赛列表失败: $e');
    }
  }
  
  // 获取比赛详情
  Future<Game> getGameDetail(int id) async {
    try {
      final response = await _dio.get('/games/$id');
      return Game.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取比赛详情失败: $e');
    }
  }
  
  // 获取球队列表
  Future<List<Team>> getTeams() async {
    try {
      final response = await _dio.get('/teams');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取球队列表失败: $e');
    }
  }
  
  // 添加关注
  Future<void> addFavorite(String type, int id) async {
    try {
      await _dio.post('/favorites', data: {
        'type': type,
        'id': id,
      });
    } catch (e) {
      throw Exception('添加关注失败: $e');
    }
  }
}
```

#### providers/games_provider.dart（状态管理）

```dart
import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../services/api_service.dart';

class GamesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Game> _games = [];
  bool _isLoading = false;
  String? _error;
  
  List<Game> get games => _games;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Game> get liveGames => 
      _games.where((g) => g.isLive).toList();
  
  List<Game> get finishedGames => 
      _games.where((g) => g.isFinished).toList();
  
  // 获取今日比赛
  Future<void> fetchTodayGames() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _games = await _apiService.getTodayGames();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 更新比赛比分（WebSocket推送）
  void updateGameScore(int gameId, int homeScore, int awayScore) {
    final index = _games.indexWhere((g) => g.id == gameId);
    if (index != -1) {
      _games[index] = _games[index].copyWith(
        homeScore: homeScore,
        awayScore: awayScore,
      );
      notifyListeners();
    }
  }
  
  // 刷新
  Future<void> refresh() => fetchTodayGames();
}
```

#### widgets/game_card.dart（比赛卡片）

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image.dart';
import '../models/game.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Live 标签
              if (game.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              // 球队对阵
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 主队
                  Expanded(
                    child: _buildTeam(
                      context,
                      game.homeTeam!,
                      game.homeScore,
                      game.homeScore > game.awayScore && game.isFinished,
                    ),
                  ),
                  
                  // 分隔符
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '-',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  
                  // 客队
                  Expanded(
                    child: _buildTeam(
                      context,
                      game.awayTeam!,
                      game.awayScore,
                      game.awayScore > game.homeScore && game.isFinished,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 比赛状态
              Text(
                _getStatusText(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: game.isLive ? Colors.red : Colors.grey,
                  fontWeight: game.isLive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTeam(
    BuildContext context,
    Team team,
    int score,
    bool isWinner,
  ) {
    return Column(
      children: [
        // Logo
        CachedNetworkImage(
          imageUrl: team.logoUrl,
          width: 60,
          height: 60,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        const SizedBox(height: 8),
        
        // 球队名
        Text(
          team.name,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // 比分
        Text(
          '$score',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isWinner ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }
  
  String _getStatusText() {
    if (game.isLive) {
      return 'Q${game.quarter} ${game.timeRemaining}';
    } else if (game.isFinished) {
      return '已结束';
    } else {
      // 格式化开始时间
      final hour = game.gameDate.hour.toString().padLeft(2, '0');
      final minute = game.gameDate.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}
```

#### screens/home/home_screen.dart（首页）

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/game_card.dart';
import '../games/game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().fetchTodayGames();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          _TeamsTab(),
          _PlayersTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: '球队',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '球员',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BuzzerBeater'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 搜索
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 通知
            },
          ),
        ],
      ),
      body: Consumer<GamesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refresh,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: CustomScrollView(
              slivers: [
                // 我的关注
                Consumer<FavoritesProvider>(
                  builder: (context, favs, _) {
                    final myGames = provider.games.where((game) =>
                      favs.isFavoriteTeam(game.homeTeamId) ||
                      favs.isFavoriteTeam(game.awayTeamId)
                    ).toList();
                    
                    if (myGames.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    
                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '我的关注',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          ...myGames.map((game) => GameCard(
                            game: game,
                            onTap: () => _navigateToGameDetail(context, game),
                          )),
                          const Divider(height: 32),
                        ],
                      ),
                    );
                  },
                ),
                
                // 今日比赛
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '今日比赛',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = provider.games[index];
                      return GameCard(
                        game: game,
                        onTap: () => _navigateToGameDetail(context, game),
                      );
                    },
                    childCount: provider.games.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _navigateToGameDetail(BuildContext context, Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(game: game),
      ),
    );
  }
}

// 其他 Tab 实现类似...
class _TeamsTab extends StatelessWidget {
  const _TeamsTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('球队页面'));
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('球员页面'));
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('个人中心'));
  }
}
```

---

## 三、后端 Go 完整方案

### 3.1 项目创建

```bash
# 1. 创建项目目录
mkdir buzzerbeater-backend
cd buzzerbeater-backend

# 2. 初始化 Go 模块
go mod init buzzerbeater

# 3. 安装依赖
go get github.com/gin-gonic/gin
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/golang-jwt/jwt/v5
go get github.com/redis/go-redis/v9
go get github.com/robfig/cron/v3
go get github.com/gorilla/websocket
```

### 3.2 完整项目结构

```
buzzerbeater-backend/
├── cmd/
│   └── server/
│       └── main.go              # 应用入口
│
├── internal/
│   ├── config/                  # 配置
│   │   └── config.go
│   │
│   ├── models/                  # 数据模型
│   │   ├── user.go
│   │   ├── team.go
│   │   ├── player.go
│   │   ├── game.go
│   │   └── favorite.go
│   │
│   ├── handlers/                # 控制器
│   │   ├── auth_handler.go
│   │   ├── game_handler.go
│   │   ├── team_handler.go
│   │   ├── player_handler.go
│   │   └── favorite_handler.go
│   │
│   ├── services/                # 业务逻辑
│   │   ├── nba_service.go       # NBA 数据同步
│   │   ├── notification_service.go
│   │   └── recommendation_service.go
│   │
│   ├── middleware/              # 中间件
│   │   ├── auth.go
│   │   ├── cors.go
│   │   └── logger.go
│   │
│   ├── database/                # 数据库
│   │   ├── postgres.go
│   │   └── redis.go
│   │
│   ├── tasks/                   # 定时任务
│   │   └── sync_games.go
│   │
│   └── utils/                   # 工具
│       ├── jwt.go
│       └── response.go
│
├── migrations/                  # 数据库迁移
│   └── 001_init.sql
│
├── scripts/                     # 脚本
│   └── setup.sh
│
├── Dockerfile
├── docker-compose.yml
├── go.mod
├── go.sum
└── README.md
```

### 3.3 核心代码示例

#### cmd/server/main.go（应用入口）

```go
package main

import (
	"log"
	"buzzerbeater/internal/config"
	"buzzerbeater/internal/database"
	"buzzerbeater/internal/handlers"
	"buzzerbeater/internal/middleware"
	"buzzerbeater/internal/tasks"
	"github.com/gin-gonic/gin"
)

func main() {
	// 加载配置
	cfg := config.LoadConfig()
	
	// 初始化数据库
	db := database.InitPostgres(cfg)
	rdb := database.InitRedis(cfg)
	
	// 启动定时任务
	go tasks.StartSyncGames(db, rdb)
	
	// 创建 Gin 实例
	r := gin.Default()
	
	// 中间件
	r.Use(middleware.CORS())
	r.Use(middleware.Logger())
	
	// 路由
	api := r.Group("/api/v1")
	{
		// 公开接口
		auth := api.Group("/auth")
		{
			authHandler := handlers.NewAuthHandler(db)
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
		}
		
		// 需要认证的接口
		protected := api.Group("")
		protected.Use(middleware.AuthRequired())
		{
			// 比赛
			gameHandler := handlers.NewGameHandler(db, rdb)
			protected.GET("/games/today", gameHandler.GetTodayGames)
			protected.GET("/games/:id", gameHandler.GetGameDetail)
			
			// 球队
			teamHandler := handlers.NewTeamHandler(db)
			protected.GET("/teams", teamHandler.GetTeams)
			protected.GET("/teams/:id", teamHandler.GetTeamDetail)
			
			// 球员
			playerHandler := handlers.NewPlayerHandler(db)
			protected.GET("/players", playerHandler.GetPlayers)
			protected.GET("/players/:id", playerHandler.GetPlayerDetail)
			
			// 收藏
			favHandler := handlers.NewFavoriteHandler(db)
			protected.POST("/favorites", favHandler.AddFavorite)
			protected.DELETE("/favorites/:id", favHandler.RemoveFavorite)
			protected.GET("/favorites", favHandler.GetMyFavorites)
		}
	}
	
	// WebSocket
	r.GET("/ws", handlers.HandleWebSocket)
	
	// 启动服务
	log.Printf("Server starting on %s", cfg.ServerAddress)
	if err := r.Run(cfg.ServerAddress); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
```

#### internal/config/config.go（配置）

```go
package config

import (
	"os"
)

type Config struct {
	ServerAddress string
	DatabaseURL   string
	RedisURL      string
	JWTSecret     string
	NBAApiKey     string
}

func LoadConfig() *Config {
	return &Config{
		ServerAddress: getEnv("SERVER_ADDRESS", ":8080"),
		DatabaseURL:   getEnv("DATABASE_URL", "postgres://user:pass@localhost:5432/buzzerbeater"),
		RedisURL:      getEnv("REDIS_URL", "localhost:6379"),
		JWTSecret:     getEnv("JWT_SECRET", "your-secret-key"),
		NBAApiKey:     getEnv("NBA_API_KEY", ""),
	}
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
```

#### internal/models/game.go（数据模型）

```go
package models

import (
	"time"
	"gorm.io/gorm"
)

type Game struct {
	ID            int       `json:"id" gorm:"primaryKey"`
	HomeTeamID    int       `json:"home_team_id"`
	AwayTeamID    int       `json:"away_team_id"`
	HomeScore     int       `json:"home_score"`
	AwayScore     int       `json:"away_score"`
	Status        string    `json:"status"`
	Quarter       *int      `json:"quarter"`
	TimeRemaining *string   `json:"time_remaining"`
	GameDate      time.Time `json:"game_date"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	
	HomeTeam      *Team     `json:"home_team,omitempty" gorm:"foreignKey:HomeTeamID"`
	AwayTeam      *Team     `json:"away_team,omitempty" gorm:"foreignKey:AwayTeamID"`
}

type Team struct {
	ID          int    `json:"id" gorm:"primaryKey"`
	Name        string `json:"name"`
	Code        string `json:"code"`
	City        string `json:"city"`
	LogoURL     string `json:"logo_url"`
	Conference  string `json:"conference"`
	Division    string `json:"division"`
}

type Player struct {
	ID         int       `json:"id" gorm:"primaryKey"`
	FirstName  string    `json:"first_name"`
	LastName   string    `json:"last_name"`
	TeamID     int       `json:"team_id"`
	Position   string    `json:"position"`
	Jersey     int       `json:"jersey"`
	Height     string    `json:"height"`
	Weight     string    `json:"weight"`
	PhotoURL   string    `json:"photo_url"`
	Team       *Team     `json:"team,omitempty" gorm:"foreignKey:TeamID"`
}

type User struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Username  string    `json:"username" gorm:"unique;not null"`
	Email     string    `json:"email" gorm:"unique"`
	Password  string    `json:"-" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Favorite struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id"`
	Type      string    `json:"type"` // "team" or "player"
	TargetID  int       `json:"target_id"`
	CreatedAt time.Time `json:"created_at"`
}
```

#### internal/handlers/game_handler.go（控制器）

```go
package handlers

import (
	"net/http"
	"strconv"
	"time"
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
	"buzzerbeater/internal/models"
)

type GameHandler struct {
	db  *gorm.DB
	rdb *redis.Client
}

func NewGameHandler(db *gorm.DB, rdb *redis.Client) *GameHandler {
	return &GameHandler{db: db, rdb: rdb}
}

// 获取今日比赛
func (h *GameHandler) GetTodayGames(c *gin.Context) {
	var games []models.Game
	
	today := time.Now().Format("2006-01-02")
	
	result := h.db.
		Preload("HomeTeam").
		Preload("AwayTeam").
		Where("DATE(game_date) = ?", today).
		Order("game_date").
		Find(&games)
	
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   result.Error.Error(),
		})
		return
	}
	
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    games,
	})
}

// 获取比赛详情
func (h *GameHandler) GetGameDetail(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Invalid game ID",
		})
		return
	}
	
	var game models.Game
	
	result := h.db.
		Preload("HomeTeam").
		Preload("AwayTeam").
		First(&game, id)
	
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"error":   "Game not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   result.Error.Error(),
		})
		return
	}
	
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    game,
	})
}
```

#### internal/services/nba_service.go（NBA数据同步）

```go
package services

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
	"gorm.io/gorm"
	"buzzerbeater/internal/models"
)

type NBAService struct {
	db     *gorm.DB
	apiKey string
}

func NewNBAService(db *gorm.DB, apiKey string) *NBAService {
	return &NBAService{
		db:     db,
		apiKey: apiKey,
	}
}

// 同步今日比赛
func (s *NBAService) SyncTodayGames() error {
	client := &http.Client{Timeout: 10 * time.Second}
	
	req, err := http.NewRequest("GET", "https://api-nba-v1.p.rapidapi.com/games", nil)
	if err != nil {
		return err
	}
	
	q := req.URL.Query()
	q.Add("date", time.Now().Format("2006-01-02"))
	req.URL.RawQuery = q.Encode()
	
	req.Header.Add("X-RapidAPI-Key", s.apiKey)
	req.Header.Add("X-RapidAPI-Host", "api-nba-v1.p.rapidapi.com")
	
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	
	var result struct {
		Response []struct {
			ID     int `json:"id"`
			Teams  struct {
				Home struct {
					ID int `json:"id"`
				} `json:"home"`
				Visitors struct {
					ID int `json:"id"`
				} `json:"visitors"`
			} `json:"teams"`
			Scores struct {
				Home struct {
					Points int `json:"points"`
				} `json:"home"`
				Visitors struct {
					Points int `json:"points"`
				} `json:"visitors"`
			} `json:"scores"`
			Status struct {
				Long  string `json:"long"`
				Clock string `json:"clock"`
			} `json:"status"`
			Periods struct {
				Current int `json:"current"`
			} `json:"periods"`
			Date struct {
				Start time.Time `json:"start"`
			} `json:"date"`
		} `json:"response"`
	}
	
	if err := json.Unmarshal(body, &result); err != nil {
		return err
	}
	
	// 更新数据库
	for _, gameData := range result.Response {
		game := models.Game{
			ID:            gameData.ID,
			HomeTeamID:    gameData.Teams.Home.ID,
			AwayTeamID:    gameData.Teams.Visitors.ID,
			HomeScore:     gameData.Scores.Home.Points,
			AwayScore:     gameData.Scores.Visitors.Points,
			Status:        gameData.Status.Long,
			Quarter:       &gameData.Periods.Current,
			TimeRemaining: &gameData.Status.Clock,
			GameDate:      gameData.Date.Start,
		}
		
		s.db.Save(&game)
	}
	
	fmt.Printf("Synced %d games\n", len(result.Response))
	return nil
}
```

#### internal/tasks/sync_games.go（定时任务）

```go
package tasks

import (
	"log"
	"time"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
	"buzzerbeater/internal/config"
	"buzzerbeater/internal/services"
)

func StartSyncGames(db *gorm.DB, rdb *redis.Client) {
	cfg := config.LoadConfig()
	nbaService := services.NewNBAService(db, cfg.NBAApiKey)
	
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	log.Println("Started game sync task")
	
	// 立即执行一次
	if err := nbaService.SyncTodayGames(); err != nil {
		log.Printf("Sync error: %v\n", err)
	}
	
	// 定时执行
	for range ticker.C {
		if err := nbaService.SyncTodayGames(); err != nil {
			log.Printf("Sync error: %v\n", err)
		}
	}
}
```

#### internal/database/postgres.go（数据库）

```go
package database

import (
	"log"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"buzzerbeater/internal/config"
	"buzzerbeater/internal/models"
)

func InitPostgres(cfg *config.Config) *gorm.DB {
	db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	
	// 自动迁移
	db.AutoMigrate(
		&models.User{},
		&models.Team{},
		&models.Player{},
		&models.Game{},
		&models.Favorite{},
	)
	
	log.Println("Database connected and migrated")
	return db
}
```

#### Dockerfile

```dockerfile
# 构建阶段
FROM golang:1.21-alpine AS builder

WORKDIR /app

# 复制 go.mod 和 go.sum
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . .

# 构建
RUN CGO_ENABLED=0 GOOS=linux go build -o buzzerbeater ./cmd/server

# 运行阶段
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# 从构建阶段复制二进制文件
COPY --from=builder /app/buzzerbeater .

EXPOSE 8080

CMD ["./buzzerbeater"]
```

#### docker-compose.yml

```yaml
version: '3.8'

services:
  # 后端服务
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://buzz:password@postgres:5432/buzzerbeater?sslmode=disable
      - REDIS_URL=redis:6379
      - JWT_SECRET=your-secret-key
      - NBA_API_KEY=your-nba-api-key
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
  
  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: buzz
      POSTGRES_PASSWORD: password
      POSTGRES_DB: buzzerbeater
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
  
  # Redis
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped

volumes:
  postgres_data:
```

---

## 四、开发流程

### 4.1 前端开发（Flutter）

```bash
# Day 1-2: 搭建基础框架
flutter create buzzerbeater
# 配置依赖、主题、路由

# Day 3-4: 实现数据模型和服务层
# models/, services/, providers/

# Day 5-7: 实现首页和比赛列表
# screens/home/, widgets/game_card.dart

# Week 2: 球队和球员页面

# Week 3: 个人中心和设置

# Week 4: 优化和测试
```

### 4.2 后端开发（Go）

```bash
# Day 1: 搭建基础框架
go mod init buzzerbeater
# 安装依赖、配置结构

# Day 2-3: 数据库和模型
# models/, database/

# Day 4-5: API 接口
# handlers/, routes

# Day 6-7: NBA 数据同步
# services/, tasks/

# Week 2: 认证和权限

# Week 3: WebSocket 实时推送

# Week 4: 优化和部署
```

---

## 五、部署方案

### 5.1 后端部署到 Fly.io

```bash
# 1. 安装 Fly CLI
curl -L https://fly.io/install.sh | sh

# 2. 登录
fly auth login

# 3. 初始化
fly launch

# 4. 创建 PostgreSQL
fly postgres create

# 5. 连接数据库
fly postgres attach

# 6. 部署
fly deploy

# 完成！后端已部署
```

### 5.2 前端发布

**iOS:**
```bash
flutter build ios --release
# 在 Xcode 中打开并上传到 App Store
```

**Android:**
```bash
flutter build apk --release
# 或
flutter build appbundle --release
# 上传到 Google Play
```

**Web:**
```bash
flutter build web
# 部署到 Vercel/Netlify
```

---

## 六、总成本

```
开发阶段：$0/月
- Fly.io 免费额度
- PostgreSQL 免费
- NBA API 免费 500次/月

小规模生产：$5-30/月
- Fly.io: $5/月
- PostgreSQL: $0-15/月
- NBA API: $0-50/月

完全免费到上线！
```

---

## 七、学习资源

### Flutter 学习
- 官方教程：https://flutter.dev/learn
- Dart 教程：https://dart.dev/guides
- 视频课程：B站搜索"Flutter入门"

### Go 学习
- 官方教程：https://go.dev/tour/
- Gin 文档：https://gin-gonic.com/docs/
- 视频课程：B站搜索"Go语言入门"

---

## 八、下一步

```bash
# 1. 创建 Flutter 项目
flutter create buzzerbeater

# 2. 创建 Go 项目
mkdir buzzerbeater-backend
cd buzzerbeater-backend
go mod init buzzerbeater

# 3. 开始编码！
```

---

**Flutter + Go = 性能 + 效率的完美组合！** 🚀

需要我提供：
1. 完整的 Flutter 项目初始化脚本？
2. Go 后端的完整代码仓库？
3. 一步步的开发教程？

告诉我，我立即帮你准备！🏀

