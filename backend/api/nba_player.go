package api

import (
	"buzzerbeater/util"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// GetNBAPlayers 获取 NBA 球员列表
func GetNBAPlayers(c *gin.Context) {
	// 可选的球队ID过滤
	teamIDStr := c.Query("team_id")
	teamID := 0
	if teamIDStr != "" {
		if id, err := strconv.Atoi(teamIDStr); err == nil {
			teamID = id
		}
	}

	players, err := getNBAClient().GetPlayers(teamID)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "获取球员列表失败: "+err.Error())
		return
	}

	util.SuccessResponse(c, http.StatusOK, players)
}

// GetNBAPlayerStats 获取球员赛季数据
func GetNBAPlayerStats(c *gin.Context) {
	playerIDStr := c.Param("id")
	playerID, err := strconv.Atoi(playerIDStr)
	if err != nil {
		util.ErrorResponse(c, http.StatusBadRequest, "无效的球员ID")
		return
	}

	// 默认获取 2024 赛季数据
	season := 2024
	if seasonStr := c.Query("season"); seasonStr != "" {
		if s, err := strconv.Atoi(seasonStr); err == nil {
			season = s
		}
	}

	stats, err := getNBAClient().GetPlayerSeasonAverages(playerID, season)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "获取球员数据失败: "+err.Error())
		return
	}

	util.SuccessResponse(c, http.StatusOK, stats)
}
