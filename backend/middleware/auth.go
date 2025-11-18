package middleware

import (
	"buzzerbeater/util"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// Auth JWT 认证中间件
func Auth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从 Header 获取 Authorization
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			util.ErrorResponse(c, http.StatusUnauthorized, "未授权")
			c.Abort()
			return
		}

		// 检查格式: "Bearer {token}"
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			util.ErrorResponse(c, http.StatusUnauthorized, "Token格式错误")
			c.Abort()
			return
		}

		tokenString := parts[1]

		// 解析并验证 Token
		userID, err := util.ParseToken(tokenString)
		if err != nil {
			util.ErrorResponse(c, http.StatusUnauthorized, "Token无效或已过期")
			c.Abort()
			return
		}

		// 将用户 ID 存入 context
		c.Set("user_id", userID)
		c.Next()
	}
}

