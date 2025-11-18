package api

import (
	"buzzerbeater/db"
	"buzzerbeater/model"
	"buzzerbeater/util"
	"net/http"

	"github.com/gin-gonic/gin"
)

// LoginRequest 登录请求
type LoginRequest struct {
	Nickname string `json:"nickname" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Token string      `json:"token"`
	User  *model.User `json:"user"`
}

// CreateSession 登录（创建会话）
func CreateSession(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, "请求参数错误")
		return
	}

	// 查询用户
	query := `
		SELECT u.id, u.nickname, u.password, u.avatar, u.team_id, u.created_at, u.updated_at,
		       t.id, t.name, t.code, t.color, t.accent
		FROM users u
		LEFT JOIN teams t ON u.team_id = t.id
		WHERE u.nickname = ?
	`

	var user model.User
	var team model.Team
	err := db.GetDB().QueryRow(query, req.Nickname).Scan(
		&user.ID, &user.Nickname, &user.Password, &user.Avatar, &user.TeamID,
		&user.CreatedAt, &user.UpdatedAt,
		&team.ID, &team.Name, &team.Code, &team.Color, &team.Accent,
	)

	if err != nil {
		util.ErrorResponse(c, http.StatusUnauthorized, "昵称或密码错误")
		return
	}

	// 验证密码
	if !util.CheckPassword(user.Password, req.Password) {
		util.ErrorResponse(c, http.StatusUnauthorized, "昵称或密码错误")
		return
	}

	// 生成 Token
	token, err := util.GenerateToken(user.ID)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "生成Token失败")
		return
	}

	// 组装响应
	user.Team = &team
	user.Password = "" // 不返回密码

	response := LoginResponse{
		Token: token,
		User:  &user,
	}

	util.SuccessResponse(c, http.StatusOK, response)
}

// DeleteSession 注销（删除会话）
func DeleteSession(c *gin.Context) {
	// 前端删除本地 Token 即可
	// 可选：将 Token 加入 Redis 黑名单
	c.Status(http.StatusNoContent)
}

