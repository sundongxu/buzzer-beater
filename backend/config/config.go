package config

import (
	"os"
)

// Config 应用配置
type Config struct {
	BallDontLieAPIKey string
}

var AppConfig *Config

// Init 初始化配置
func Init() {
	AppConfig = &Config{
		BallDontLieAPIKey: getEnv("BALLDONTLIE_API_KEY", "3b8fe95f-2b5b-4e57-984d-d6e76c7e7606"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
