package api

import (
	"buzzerbeater/external"
	"buzzerbeater/util"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
)

var (
	nbaClient     *external.NBAClient
	nbaClientOnce sync.Once
)

// getNBAClient 获取 NBA 客户端实例（延迟初始化）
func getNBAClient() *external.NBAClient {
	nbaClientOnce.Do(func() {
		nbaClient = external.NewNBAClient()
	})
	return nbaClient
}

// GetNBATeams 获取 NBA 球队列表
func GetNBATeams(c *gin.Context) {
	teams, err := getNBAClient().GetTeams()
	if err != nil {
		util.ErrorResponse(c, http.StatusInternalServerError, "获取球队列表失败: "+err.Error())
		return
	}

	util.SuccessResponse(c, http.StatusOK, teams)
}
