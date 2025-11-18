# BuzzerBeater Backend

**让篮球更有趣，让球迷更懂球，让打球更容易**

## 技术栈

- Go 1.25
- Gin Web Framework

## 快速开始

### 安装依赖

```bash
go mod download
```

### 运行项目

```bash
go run main.go
```

服务将在 `http://localhost:8080` 启动

### 健康检查

```bash
curl http://localhost:8080/health
```

返回示例：
```json
{
  "status": "ok",
  "message": "BuzzerBeater API is running"
}
```

## 项目结构

```
backend/
├── api/              # API 定义（保留）
├── cmd/              # 命令行工具（保留）
├── config/           # 配置文件（保留）
├── internal/         # 私有应用代码（保留）
├── pkg/              # 公共库代码（保留）
├── main.go           # 主程序入口
├── go.mod            # Go 模块依赖
├── go.sum            # 依赖版本锁定
└── README.md         # 项目说明
```

