package api

import (
	"buzzerbeater/db"
	"buzzerbeater/model"
	"buzzerbeater/util"
	"database/sql"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// RegisterResponse 注册响应
type RegisterResponse struct {
	ID        int         `json:"id"`
	Nickname  string      `json:"nickname"`
	Avatar    string      `json:"avatar"`
	Team      *model.Team `json:"team"`
	Token     string      `json:"token"`
	CreatedAt string      `json:"created_at"` // 添加创建时间
}

// CreateUser 注册用户
func CreateUser(c *gin.Context) {
	// 解析表单
	nickname := c.PostForm("nickname")
	password := c.PostForm("password")
	teamIDStr := c.PostForm("team_id")
	file, err := c.FormFile("avatar")

	// 验证参数
	if nickname == "" || password == "" || teamIDStr == "" || err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, "请填写完整信息")
		return
	}

	// 验证密码长度
	if len(password) < 6 {
		util.ErrorResponse(c, http.StatusBadRequest, "密码长度至少6位")
		return
	}

	// 验证 team_id
	teamID, err := strconv.Atoi(teamIDStr)
	if err != nil || teamID < 1 || teamID > 6 {
		util.ErrorResponse(c, http.StatusBadRequest, "请选择有效的球队")
		return
	}

	// 检查昵称是否已存在
	var exists bool
	checkQuery := "SELECT EXISTS(SELECT 1 FROM users WHERE nickname = ?)"
	db.GetDB().QueryRow(checkQuery, nickname).Scan(&exists)
	if exists {
		util.ErrorResponse(c, http.StatusConflict, "昵称已被使用")
		return
	}

	// 保存头像文件
	avatarPath, err := util.SaveAvatar(file)
	if err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	// 加密密码
	hashedPassword, err := util.HashPassword(password)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "密码加密失败")
		return
	}

	// 插入用户记录
	insertQuery := `
		INSERT INTO users (nickname, password, avatar, team_id) 
		VALUES (?, ?, ?, ?)
	`
	result, err := db.GetDB().Exec(insertQuery, nickname, hashedPassword, avatarPath, teamID)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "创建用户失败")
		return
	}

	// 获取新用户 ID
	userID, _ := result.LastInsertId()

	// 查询球队信息
	var team model.Team
	teamQuery := "SELECT id, name, code, color, accent FROM teams WHERE id = ?"
	db.GetDB().QueryRow(teamQuery, teamID).Scan(&team.ID, &team.Name, &team.Code, &team.Color, &team.Accent)

	// 生成 Token（注册后自动登录）
	token, err := util.GenerateToken(int(userID))
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "生成Token失败")
		return
	}

	// 查询创建时间
	var createdAt string
	db.GetDB().QueryRow("SELECT created_at FROM users WHERE id = ?", userID).Scan(&createdAt)

	// 返回响应
	response := RegisterResponse{
		ID:        int(userID),
		Nickname:  nickname,
		Avatar:    avatarPath,
		Team:      &team,
		Token:     token,
		CreatedAt: createdAt,
	}

	util.SuccessResponse(c, http.StatusCreated, response)
}

// GetCurrentUser 获取当前用户信息
func GetCurrentUser(c *gin.Context) {
	// 从 context 获取用户 ID（由认证中间件设置）
	userID, exists := c.Get("user_id")
	if !exists {
		util.ErrorResponse(c, http.StatusUnauthorized, "未授权")
		return
	}

	// 查询用户信息
	query := `
		SELECT u.id, u.nickname, u.avatar, u.team_id, u.created_at, u.updated_at,
		       t.id, t.name, t.code, t.color, t.accent
		FROM users u
		LEFT JOIN teams t ON u.team_id = t.id
		WHERE u.id = ?
	`

	var user model.User
	var team model.Team
	err := db.GetDB().QueryRow(query, userID).Scan(
		&user.ID, &user.Nickname, &user.Avatar, &user.TeamID,
		&user.CreatedAt, &user.UpdatedAt,
		&team.ID, &team.Name, &team.Code, &team.Color, &team.Accent,
	)

	if err == sql.ErrNoRows {
		util.ErrorResponse(c, http.StatusNotFound, "用户不存在")
		return
	}

	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "查询用户失败")
		return
	}

	user.Team = &team
	util.SuccessResponse(c, http.StatusOK, user)
}

// UpdateAvatar 更新头像
func UpdateAvatar(c *gin.Context) {
	// 从 context 获取用户 ID
	userID, exists := c.Get("user_id")
	if !exists {
		util.ErrorResponse(c, http.StatusUnauthorized, "未授权")
		return
	}

	// 获取新头像文件
	file, err := c.FormFile("avatar")
	if err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, "请选择头像文件")
		return
	}

	// 查询旧头像路径
	var oldAvatar string
	db.GetDB().QueryRow("SELECT avatar FROM users WHERE id = ?", userID).Scan(&oldAvatar)

	// 保存新头像
	newAvatarPath, err := util.SaveAvatar(file)
	if err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	// 更新数据库
	updateQuery := "UPDATE users SET avatar = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?"
	_, err = db.GetDB().Exec(updateQuery, newAvatarPath, userID)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "更新头像失败")
		return
	}

	// 删除旧头像文件
	if oldAvatar != "" {
		util.DeleteAvatar(oldAvatar)
	}

	// 返回新头像路径
	util.SuccessResponse(c, http.StatusOK, gin.H{"avatar": newAvatarPath})
}

// UpdateTeam 更新主队
func UpdateTeam(c *gin.Context) {
	// 从 context 获取用户 ID
	userID, exists := c.Get("user_id")
	if !exists {
		util.ErrorResponse(c, http.StatusUnauthorized, "未授权")
		return
	}

	// 获取新的 team_id
	var req struct {
		TeamID int `json:"team_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, "请提供有效的球队ID")
		return
	}

	// 验证球队是否存在
	var teamExists bool
	checkQuery := "SELECT EXISTS(SELECT 1 FROM teams WHERE id = ?)"
	db.GetDB().QueryRow(checkQuery, req.TeamID).Scan(&teamExists)
	if !teamExists {
		util.ErrorResponse(c, http.StatusBadRequest, "球队不存在")
		return
	}

	// 更新用户的主队
	updateQuery := "UPDATE users SET team_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?"
	_, err := db.GetDB().Exec(updateQuery, req.TeamID, userID)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "更新主队失败")
		return
	}

	// 查询新的球队信息
	var team model.Team
	teamQuery := "SELECT id, name, code, color, accent FROM teams WHERE id = ?"
	err = db.GetDB().QueryRow(teamQuery, req.TeamID).Scan(
		&team.ID, &team.Name, &team.Code, &team.Color, &team.Accent,
	)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "查询球队信息失败")
		return
	}

	// 返回新的球队信息
	util.SuccessResponse(c, http.StatusOK, team)
}
