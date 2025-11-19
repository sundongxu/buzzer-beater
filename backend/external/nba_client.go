package external

import (
	"buzzerbeater/config"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

const ballDontLieBaseURL = "https://api.balldontlie.io"

// cacheEntry 缓存条目
type cacheEntry struct {
	data      []byte
	expiresAt time.Time
}

// NBAClient NBA API 客户端
type NBAClient struct {
	httpClient *http.Client
	apiKey     string
	cache      map[string]*cacheEntry
	cacheMu    sync.RWMutex
}

// NewNBAClient 创建 NBA API 客户端
func NewNBAClient() *NBAClient {
	return &NBAClient{
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
		apiKey: config.AppConfig.BallDontLieAPIKey,
		cache:  make(map[string]*cacheEntry),
	}
}

// doRequest 执行 HTTP 请求（带缓存）
func (c *NBAClient) doRequest(endpoint string) ([]byte, error) {
	// 检查缓存
	c.cacheMu.RLock()
	if entry, exists := c.cache[endpoint]; exists {
		if time.Now().Before(entry.expiresAt) {
			c.cacheMu.RUnlock()
			return entry.data, nil
		}
	}
	c.cacheMu.RUnlock()

	// 发起 API 请求
	url := ballDontLieBaseURL + endpoint
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	// 设置 Authorization header
	req.Header.Set("Authorization", c.apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status code: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	// 保存到缓存（球队数据缓存1小时，球员数据缓存5分钟）
	cacheDuration := 5 * time.Minute
	if endpoint == "/nba/v1/teams" {
		cacheDuration = 1 * time.Hour // 球队数据变化少，缓存时间长
	}

	c.cacheMu.Lock()
	c.cache[endpoint] = &cacheEntry{
		data:      body,
		expiresAt: time.Now().Add(cacheDuration),
	}
	c.cacheMu.Unlock()

	return body, nil
}

// NBATeamResponse 球队响应
type NBATeamResponse struct {
	Data []NBATeam `json:"data"`
	Meta struct {
		NextCursor int `json:"next_cursor"`
		PerPage    int `json:"per_page"`
	} `json:"meta"`
}

// NBATeam 球队信息
type NBATeam struct {
	ID           int    `json:"id"`
	Conference   string `json:"conference"`
	Division     string `json:"division"`
	City         string `json:"city"`
	Name         string `json:"name"`
	FullName     string `json:"full_name"`
	FullNameZh   string `json:"full_name_zh"` // 中文名称
	Abbreviation string `json:"abbreviation"`
	LogoURL      string `json:"logo_url"` // 队标 URL (SVG格式)
	BgColor      string `json:"bg_color"` // 背景色 (与队标配色搭配)
}

// GetTeams 获取所有 NBA 球队（只返回现役30支球队）
func (c *NBAClient) GetTeams() ([]NBATeam, error) {
	body, err := c.doRequest("/nba/v1/teams")
	if err != nil {
		return nil, err
	}

	var response NBATeamResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, err
	}

	// 过滤掉历史球队，只保留现役的30支球队
	activeTeams := filterActiveTeams(response.Data)
	return activeTeams, nil
}

// filterActiveTeams 过滤出现役的30支NBA球队
func filterActiveTeams(teams []NBATeam) []NBATeam {
	// 现役30支球队的全名白名单（2024-25赛季）
	// 使用全名更准确，避免历史球队混入
	activeTeamNames := map[string]bool{
		"Atlanta Hawks":          true,
		"Boston Celtics":         true,
		"Brooklyn Nets":          true,
		"Charlotte Hornets":      true,
		"Chicago Bulls":          true,
		"Cleveland Cavaliers":    true,
		"Dallas Mavericks":       true,
		"Denver Nuggets":         true,
		"Detroit Pistons":        true,
		"Golden State Warriors":  true,
		"Houston Rockets":        true,
		"Indiana Pacers":         true,
		"LA Clippers":            true,
		"Los Angeles Lakers":     true,
		"Memphis Grizzlies":      true,
		"Miami Heat":             true,
		"Milwaukee Bucks":        true,
		"Minnesota Timberwolves": true,
		"New Orleans Pelicans":   true,
		"New York Knicks":        true,
		"Oklahoma City Thunder":  true,
		"Orlando Magic":          true,
		"Philadelphia 76ers":     true,
		"Phoenix Suns":           true,
		"Portland Trail Blazers": true,
		"Sacramento Kings":       true,
		"San Antonio Spurs":      true,
		"Toronto Raptors":        true,
		"Utah Jazz":              true,
		"Washington Wizards":     true,
	}

	// 中文名称、队标和背景色映射（使用 ESPN CDN 提供的高质量透明背景 PNG）
	teamInfoMap := map[string]struct {
		zhName  string
		logoURL string
		bgColor string
	}{
		"Atlanta Hawks":          {"亚特兰大老鹰", "https://a.espncdn.com/i/teamlogos/nba/500/atl.png", "#E03A3E"},
		"Boston Celtics":         {"波士顿凯尔特人", "https://a.espncdn.com/i/teamlogos/nba/500/bos.png", "#007A33"},
		"Brooklyn Nets":          {"布鲁克林篮网", "https://a.espncdn.com/i/teamlogos/nba/500/bkn.png", "#000000"},
		"Charlotte Hornets":      {"夏洛特黄蜂", "https://a.espncdn.com/i/teamlogos/nba/500/cha.png", "#1D1160"},
		"Chicago Bulls":          {"芝加哥公牛", "https://a.espncdn.com/i/teamlogos/nba/500/chi.png", "#CE1141"},
		"Cleveland Cavaliers":    {"克利夫兰骑士", "https://a.espncdn.com/i/teamlogos/nba/500/cle.png", "#860038"},
		"Dallas Mavericks":       {"达拉斯独行侠", "https://a.espncdn.com/i/teamlogos/nba/500/dal.png", "#00538C"},
		"Denver Nuggets":         {"丹佛掘金", "https://a.espncdn.com/i/teamlogos/nba/500/den.png", "#0E2240"},
		"Detroit Pistons":        {"底特律活塞", "https://a.espncdn.com/i/teamlogos/nba/500/det.png", "#C8102E"},
		"Golden State Warriors":  {"金州勇士", "https://a.espncdn.com/i/teamlogos/nba/500/gs.png", "#1D428A"},
		"Houston Rockets":        {"休斯顿火箭", "https://a.espncdn.com/i/teamlogos/nba/500/hou.png", "#CE1141"},
		"Indiana Pacers":         {"印第安纳步行者", "https://a.espncdn.com/i/teamlogos/nba/500/ind.png", "#002D62"},
		"LA Clippers":            {"洛杉矶快船", "https://a.espncdn.com/i/teamlogos/nba/500/lac.png", "#C8102E"},
		"Los Angeles Lakers":     {"洛杉矶湖人", "https://a.espncdn.com/i/teamlogos/nba/500/lal.png", "#552583"},
		"Memphis Grizzlies":      {"孟菲斯灰熊", "https://a.espncdn.com/i/teamlogos/nba/500/mem.png", "#5D76A9"},
		"Miami Heat":             {"迈阿密热火", "https://a.espncdn.com/i/teamlogos/nba/500/mia.png", "#98002E"},
		"Milwaukee Bucks":        {"密尔沃基雄鹿", "https://a.espncdn.com/i/teamlogos/nba/500/mil.png", "#00471B"},
		"Minnesota Timberwolves": {"明尼苏达森林狼", "https://a.espncdn.com/i/teamlogos/nba/500/min.png", "#0C2340"},
		"New Orleans Pelicans":   {"新奥尔良鹈鹕", "https://a.espncdn.com/i/teamlogos/nba/500/no.png", "#0C2340"},
		"New York Knicks":        {"纽约尼克斯", "https://a.espncdn.com/i/teamlogos/nba/500/ny.png", "#006BB6"},
		"Oklahoma City Thunder":  {"俄克拉荷马城雷霆", "https://a.espncdn.com/i/teamlogos/nba/500/okc.png", "#007AC1"},
		"Orlando Magic":          {"奥兰多魔术", "https://a.espncdn.com/i/teamlogos/nba/500/orl.png", "#0077C0"},
		"Philadelphia 76ers":     {"费城76人", "https://a.espncdn.com/i/teamlogos/nba/500/phi.png", "#006BB6"},
		"Phoenix Suns":           {"菲尼克斯太阳", "https://a.espncdn.com/i/teamlogos/nba/500/phx.png", "#1D1160"},
		"Portland Trail Blazers": {"波特兰开拓者", "https://a.espncdn.com/i/teamlogos/nba/500/por.png", "#E03A3E"},
		"Sacramento Kings":       {"萨克拉门托国王", "https://a.espncdn.com/i/teamlogos/nba/500/sac.png", "#5A2D81"},
		"San Antonio Spurs":      {"圣安东尼奥马刺", "https://a.espncdn.com/i/teamlogos/nba/500/sa.png", "#C4CED4"},
		"Toronto Raptors":        {"多伦多猛龙", "https://a.espncdn.com/i/teamlogos/nba/500/tor.png", "#CE1141"},
		"Utah Jazz":              {"犹他爵士", "https://a.espncdn.com/i/teamlogos/nba/500/utah.png", "#002B5C"},
		"Washington Wizards":     {"华盛顿奇才", "https://a.espncdn.com/i/teamlogos/nba/500/wsh.png", "#002B5C"},
	}

	var active []NBATeam
	for _, team := range teams {
		// 白名单检查 + conference非空检查（历史球队没有conference）
		if activeTeamNames[team.FullName] && team.Conference != "" {
			// 添加中文名称、队标和背景色
			if info, ok := teamInfoMap[team.FullName]; ok {
				team.FullNameZh = info.zhName
				team.LogoURL = info.logoURL
				team.BgColor = info.bgColor
			}
			active = append(active, team)
		}
	}
	return active
}

// NBAPlayerResponse 球员响应
type NBAPlayerResponse struct {
	Data []NBAPlayer `json:"data"`
	Meta struct {
		NextCursor int `json:"next_cursor"`
		PerPage    int `json:"per_page"`
	} `json:"meta"`
}

// NBAPlayer 球员信息
type NBAPlayer struct {
	ID           int     `json:"id"`
	FirstName    string  `json:"first_name"`
	LastName     string  `json:"last_name"`
	Position     string  `json:"position"`
	Height       string  `json:"height"`
	Weight       string  `json:"weight"`
	JerseyNumber string  `json:"jersey_number"`
	College      string  `json:"college"`
	Country      string  `json:"country"`
	DraftYear    int     `json:"draft_year"`
	DraftRound   int     `json:"draft_round"`
	DraftNumber  int     `json:"draft_number"`
	Team         NBATeam `json:"team"`
}

// GetPlayers 获取球员列表（可按球队筛选）
func (c *NBAClient) GetPlayers(teamID int) ([]NBAPlayer, error) {
	endpoint := "/nba/v1/players?per_page=25"
	if teamID > 0 {
		endpoint += fmt.Sprintf("&team_ids[]=%d", teamID)
	}

	body, err := c.doRequest(endpoint)
	if err != nil {
		return nil, err
	}

	var response NBAPlayerResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, err
	}

	return response.Data, nil
}

// NBASeasonAveragesResponse 赛季数据响应
type NBASeasonAveragesResponse struct {
	Data []NBASeasonAverage `json:"data"`
	Meta struct {
		NextCursor int `json:"next_cursor"`
		PerPage    int `json:"per_page"`
	} `json:"meta"`
}

// NBASeasonAverage 赛季平均数据
type NBASeasonAverage struct {
	PlayerID    int     `json:"player_id"`
	Season      int     `json:"season"`
	GamesPlayed int     `json:"games_played"`
	Pts         float64 `json:"pts"`
	Ast         float64 `json:"ast"`
	Reb         float64 `json:"reb"`
	Stl         float64 `json:"stl"`
	Blk         float64 `json:"blk"`
	Turnover    float64 `json:"turnover"`
	Min         string  `json:"min"`
	Fgm         float64 `json:"fgm"`
	Fga         float64 `json:"fga"`
	FgPct       float64 `json:"fg_pct"`
	Fg3m        float64 `json:"fg3m"`
	Fg3a        float64 `json:"fg3a"`
	Fg3Pct      float64 `json:"fg3_pct"`
	Ftm         float64 `json:"ftm"`
	Fta         float64 `json:"fta"`
	FtPct       float64 `json:"ft_pct"`
	Oreb        float64 `json:"oreb"`
	Dreb        float64 `json:"dreb"`
}

// GetPlayerSeasonAverages 获取球员赛季平均数据
func (c *NBAClient) GetPlayerSeasonAverages(playerID int, season int) (*NBASeasonAverage, error) {
	endpoint := fmt.Sprintf("/nba/v1/season_averages?season=%d&player_ids[]=%d", season, playerID)

	body, err := c.doRequest(endpoint)
	if err != nil {
		return nil, err
	}

	var response NBASeasonAveragesResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, err
	}

	if len(response.Data) == 0 {
		return nil, fmt.Errorf("no season averages found")
	}

	return &response.Data[0], nil
}
