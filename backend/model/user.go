package model

import "time"

// User 用户模型
type User struct {
	ID        int       `json:"id"`
	Nickname  string    `json:"nickname"`
	Password  string    `json:"-"` // 不返回给前端
	Avatar    string    `json:"avatar"`
	TeamID    int       `json:"-"`
	Team      *Team     `json:"team,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

