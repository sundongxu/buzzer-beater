import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/auth.dart';
import 'screen/login.dart';
import 'screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BuzzerBeaterApp());
}

class BuzzerBeaterApp extends StatelessWidget {
  const BuzzerBeaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Auth()..init(),
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          // 正在加载
          if (auth.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.sports_basketball,
                        size: 80,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 24),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          }

          // 已加载，根据认证状态显示页面
          return MaterialApp(
            title: 'BuzzerBeater',
            debugShowCheckedModeBanner: false,
            theme: auth.theme, // 动态主题
            home: auth.isAuth ? const Home() : const Login(),
          );
        },
      ),
    );
  }
}
