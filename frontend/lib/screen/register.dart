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
      appBar: AppBar(
        title: const Text('注册账号'),
      ),
      body: SafeArea(
        child: _isLoadingTeams
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 头像选择
                      Center(
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child:                           FutureBuilder<Uint8List>(
                            future: _avatarFile?.readAsBytes(),
                            builder: (context, snapshot) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                  image: snapshot.hasData
                                      ? DecorationImage(
                                          image: MemoryImage(snapshot.data!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _avatarFile == null
                                    ? const Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey,
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '点击上传头像',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      // 昵称
                      TextFormField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          labelText: '昵称',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
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
                          labelText: '密码（至少6位）',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
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
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                        decoration: const InputDecoration(
                          labelText: '选择主队',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_basketball),
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

                      // 注册按钮
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('注册', style: TextStyle(fontSize: 16)),
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
    );
  }
}

