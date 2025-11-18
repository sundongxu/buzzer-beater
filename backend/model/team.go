package model

// Team 球队模型
type Team struct {
	ID     int    `json:"id"`
	Name   string `json:"name"`
	Code   string `json:"code"`
	Color  string `json:"color"`
	Accent string `json:"accent"`
}

