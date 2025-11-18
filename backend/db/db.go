package db

import (
	"database/sql"
	_ "embed"
	"log"

	_ "github.com/mattn/go-sqlite3"
)

//go:embed schema.sql
var schemaSQL string

var db *sql.DB

// Init 初始化数据库
func Init() {
	var err error
	db, err = sql.Open("sqlite3", "./buzzerbeater.db")
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}

	// 执行 schema
	if _, err := db.Exec(schemaSQL); err != nil {
		log.Fatal("Failed to execute schema:", err)
	}

	log.Println("Database initialized successfully")
}

// Close 关闭数据库连接
func Close() {
	if db != nil {
		db.Close()
	}
}

// GetDB 获取数据库实例
func GetDB() *sql.DB {
	return db
}

