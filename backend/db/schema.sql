-- 球队表（预置数据）
CREATE TABLE IF NOT EXISTS teams (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    color TEXT NOT NULL,
    accent TEXT NOT NULL
);

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nickname TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    avatar TEXT NOT NULL,
    team_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- 创建索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);
CREATE INDEX IF NOT EXISTS idx_users_team ON users(team_id);

-- 插入球队数据
INSERT OR IGNORE INTO teams (id, name, code, color, accent) VALUES
(1, '湖人', 'LAL', '#552583', '#FDB927'),
(2, '凯尔特人', 'BOS', '#007A33', '#BA9653'),
(3, '勇士', 'GSW', '#1D428A', '#FFC72C'),
(4, '公牛', 'CHI', '#CE1141', '#000000'),
(5, '马刺', 'SAS', '#C4CED4', '#000000'),
(6, '雷霆', 'OKC', '#007AC1', '#EF3B24');

