# 🏀 BuzzerBeater

**让篮球更有趣，让球迷更懂球，让打球更容易**

## 项目结构

```
BuzzerBeater/
├── backend/          # Go + Gin 后端
│   ├── api/         # API 处理器
│   ├── db/          # 数据库
│   ├── middleware/  # 中间件
│   ├── model/       # 数据模型
│   ├── util/        # 工具函数
│   └── main.go      # 入口
│
├── frontend/         # Flutter 前端
│   ├── lib/
│   │   ├── config/  # 配置
│   │   ├── model/   # 数据模型
│   │   ├── provider/# 状态管理
│   │   ├── screen/  # 页面
│   │   ├── service/ # 服务层
│   │   └── main.dart
│   └── pubspec.yaml
│
└── doc/             # 文档
```

## 快速开始

### 一、后端启动

#### 1. 进入后端目录
```bash
cd backend
```

#### 2. 安装依赖
```bash
go mod download
```

#### 3. 运行后端
```bash
go run main.go
```

后端将在 `http://localhost:8080` 启动

#### 4. 测试健康检查
```bash
curl http://localhost:8080/health
```

### 二、前端启动

#### 1. 进入前端目录
```bash
cd frontend
```

#### 2. 安装依赖
```bash
flutter pub get
```

#### 3. 运行前端（Web）
```bash
flutter run -d chrome
```

或者运行在模拟器/真机：
```bash
flutter run -d ios       # iOS 模拟器
flutter run -d android   # Android 模拟器
```

## 功能说明

### ✅ 已实现功能

1. **用户注册**
   - 昵称注册（唯一性验证）
   - 密码加密（bcrypt）
   - 头像上传（本地存储）
   - 选择主队（6支NBA球队）

2. **用户登录**
   - 昵称 + 密码登录
   - JWT Token 认证
   - Token 本地存储

3. **用户注销**
   - 清除本地 Token
   - 跳转回登录页

4. **动态主题**
   - 根据用户主队自动切换主题色
   - 支持6支球队配色

5. **主队系统**
   - 湖人（紫金）
   - 凯尔特人（绿色）
   - 勇士（蓝金）
   - 公牛（红黑）
   - 马刺（银黑）
   - 雷霆（蓝橙）

## API 文档

### 公开接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/users | 注册用户 |
| POST | /api/session | 登录 |
| GET | /api/teams | 获取球队列表 |
| GET | /health | 健康检查 |

### 需要认证的接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/users/me | 获取当前用户 |
| PUT | /api/users/me/avatar | 更新头像 |
| DELETE | /api/session | 注销 |

## 技术栈

### 后端
- Go 1.25
- Gin (Web框架)
- SQLite (数据库)
- JWT (认证)
- bcrypt (密码加密)

### 前端
- Flutter 3.5+
- Dart 3.5+
- Provider (状态管理)
- Dio (网络请求)
- SharedPreferences (本地存储)
- ImagePicker (图片选择)

## 数据库

使用 SQLite，数据库文件：`backend/buzzerbeater.db`

### 表结构

**users 表**：
- id: 主键
- nickname: 昵称（唯一）
- password: 密码哈希
- avatar: 头像路径
- team_id: 主队ID
- created_at: 创建时间
- updated_at: 更新时间

**teams 表**（预置数据）：
- id: 主键
- name: 球队名称
- code: 球队代码
- color: 主色
- accent: 辅助色

## 目录说明

### 后端目录
- `api/` - API 处理器（user.go, session.go, team.go）
- `db/` - 数据库初始化和 schema
- `middleware/` - JWT 认证中间件
- `model/` - 数据模型
- `util/` - 工具函数（JWT, 密码, 文件上传）
- `uploads/` - 上传文件目录（运行时生成）

### 前端目录
- `config/` - 配置常量
- `model/` - 数据模型
- `provider/` - 状态管理
- `screen/` - 页面（login, register, home）
- `service/` - 服务层（API, Storage）

## 常见问题

### 1. 后端启动失败？
- 检查端口 8080 是否被占用
- 确保 Go 版本 >= 1.21

### 2. 前端无法连接后端？
- 检查后端是否已启动
- 检查 `frontend/lib/config/constants.dart` 中的 API 地址

### 3. 图片上传失败？
- 检查图片格式（支持 JPG/PNG/WEBP）
- 检查图片大小（< 5MB）

### 4. 数据库错误？
- 删除 `backend/buzzerbeater.db` 重新启动后端

## 开发计划

- [ ] 密码找回功能
- [ ] 用户信息编辑
- [ ] 主队更换
- [ ] 比赛数据展示
- [ ] 球员数据查询
- [ ] 实时比分推送
- [ ] 社交功能

## 许可证

MIT License

