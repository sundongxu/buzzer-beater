import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../model/team.dart';
import '../provider/auth.dart';
import '../service/api.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _avatarFile;
  Team? _selectedTeam;
  List<Team> _teams = [];
  bool _isLoading = false;
  bool _isLoadingTeams = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    try {
      final data = await API.getTeams();
      setState(() {
        _teams = data.map((json) => Team.fromJson(json)).toList();
        _isLoadingTeams = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载球队列表失败：${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _avatarFile = pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败：${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_avatarFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传头像')),
      );
      return;
    }

    if (_selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择主队')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<Auth>().register(
            nickname: _nicknameController.text.trim(),
            password: _passwordController.text,
            avatar: _avatarFile!,
            teamId: _selectedTeam!.id,
          );

      // 注册成功，显示提示并等待 MaterialApp 自动跳转到首页
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // 短暂延迟后返回，让 MaterialApp 检测到 auth 状态变化
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注册失败：${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('注册账号', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        // 与登录页一致的渐变背景 - 柔和版本
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB88C),
              Color(0xFFFFC896),
              Color(0xFFFFD6A5),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoadingTeams
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 头像选择 - 更酷的设计
                          Center(
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: _pickAvatar,
                                  child: FutureBuilder<Uint8List>(
                                    future: _avatarFile?.readAsBytes(),
                                    builder: (context, snapshot) {
                                      return Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: snapshot.hasData
                                              ? null
                                              : const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF8A65),
                                                    Color(0xFFF7931E)
                                                  ],
                                                ),
                                          color: snapshot.hasData
                                              ? null
                                              : Colors.grey[200],
                                          image: snapshot.hasData
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                      snapshot.data!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          border: Border.all(
                                            color: const Color(0xFFFF8A65),
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF8A65)
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: _avatarFile == null
                                            ? const Icon(
                                                Icons.add_a_photo,
                                                size: 40,
                                                color: Colors.white,
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                                // 相机图标角标
                                if (_avatarFile == null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Color(0xFFFF8A65),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '点击上传头像',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 昵称
                          TextFormField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              labelText: '昵称',
                              hintText: '输入你的昵称',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person,
                                  color: Color(0xFFFF8A65)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入昵称';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 密码
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: '密码',
                              hintText: '至少6位',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock,
                                  color: Color(0xFFFF8A65)),
                              filled: true,
                              fillColor: Colors.grey[50],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入密码';
                              }
                              if (value.length < 6) {
                                return '密码长度至少6位';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 确认密码
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: '确认密码',
                              hintText: '再次输入密码',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Color(0xFFFF8A65)),
                              filled: true,
                              fillColor: Colors.grey[50],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword =
                                      !_obscureConfirmPassword);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请再次输入密码';
                              }
                              if (value != _passwordController.text) {
                                return '两次密码不一致';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 球队选择
                          DropdownButtonFormField<Team>(
                            value: _selectedTeam,
                            decoration: InputDecoration(
                              labelText: '选择主队',
                              hintText: '选择你支持的球队',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.sports_basketball,
                                  color: Color(0xFFFF8A65)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _teams.map((team) {
                              return DropdownMenuItem<Team>(
                                value: team,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: team.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(team.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (team) {
                              setState(() => _selectedTeam = team);
                            },
                            validator: (value) {
                              if (value == null) {
                                return '请选择主队';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // 注册按钮 - 渐变效果
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF8A65), Color(0xFFFFAB91)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF8A65).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      '注册',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 登录链接
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('已有账号？'),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('立即登录'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
