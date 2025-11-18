package api

import (
	"buzzerbeater/db"
	"buzzerbeater/model"
	"buzzerbeater/util"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetTeams 获取球队列表
func GetTeams(c *gin.Context) {
	query := `
		SELECT id, name, code, color, accent 
		FROM teams 
		ORDER BY id
	`

	rows, err := db.GetDB().Query(query)
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "获取球队列表失败")
		return
	}
	defer rows.Close()

	teams := []model.Team{}
	for rows.Next() {
		var team model.Team
		if err := rows.Scan(&team.ID, &team.Name, &team.Code, &team.Color, &team.Accent); err != nil {
			continue
		}
		teams = append(teams, team)
	}

	util.SuccessResponse(c, http.StatusOK, teams)
}

