package util

import "github.com/gin-gonic/gin"

// ErrorResponse 返回错误响应
func ErrorResponse(c *gin.Context, status int, message string) {
	c.JSON(status, gin.H{"error": message})
}

// SuccessResponse 返回成功响应
func SuccessResponse(c *gin.Context, status int, data interface{}) {
	c.JSON(status, data)
}

