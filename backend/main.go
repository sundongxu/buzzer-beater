package main

import (
	"buzzerbeater/api"
	"buzzerbeater/config"
	"buzzerbeater/db"
	"buzzerbeater/middleware"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化配置
	config.Init()

	// 初始化数据库
	db.Init()
	defer db.Close()

	// 创建 Gin 实例
	r := gin.Default()

	// CORS 中间件（允许 Web 跨域访问）
	r.Use(middleware.CORS())

	// 静态文件服务（头像访问）
	r.Static("/uploads", "./uploads")

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "BuzzerBeater API is running",
		})
	})

	// API 路由
	apiGroup := r.Group("/api")
	{
		// ========== 公开接口 ==========
		apiGroup.POST("/users", api.CreateUser)      // 注册
		apiGroup.POST("/session", api.CreateSession) // 登录
		apiGroup.GET("/teams", api.GetTeams)         // 球队列表（本地数据）

		// NBA 数据（公开）
		apiGroup.GET("/nba/teams", api.GetNBATeams)     // NBA 球队列表
		apiGroup.GET("/nba/players", api.GetNBAPlayers) // NBA 球员列表

		// ========== 需要认证的接口 ==========
		authGroup := apiGroup.Group("")
		authGroup.Use(middleware.Auth())
		{
			// 用户资源
			authGroup.GET("/users/me", api.GetCurrentUser)      // 获取当前用户
			authGroup.PUT("/users/me/avatar", api.UpdateAvatar) // 更新头像

			// 会话资源
			authGroup.DELETE("/session", api.DeleteSession) // 注销

			// NBA 数据（需要认证）
			authGroup.GET("/nba/players/:id/stats", api.GetNBAPlayerStats) // 球员统计
		}
	}

	// 启动服务器
	log.Println("Server starting on :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
