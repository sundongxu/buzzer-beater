package util

import (
	"errors"
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
)

const (
	maxFileSize = 5 * 1024 * 1024 // 5MB
	uploadDir   = "./uploads/avatars"
)

// SaveAvatar 保存头像文件
func SaveAvatar(file *multipart.FileHeader) (string, error) {
	// 验证文件大小
	if file.Size > maxFileSize {
		return "", errors.New("文件大小不能超过5MB")
	}

	// 验证文件类型
	contentType := file.Header.Get("Content-Type")
	if !isAllowedImageType(contentType) {
		return "", errors.New("只支持 JPG、PNG、WEBP 格式")
	}

	// 确保上传目录存在
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return "", err
	}

	// 生成唯一文件名
	ext := filepath.Ext(file.Filename)
	filename := uuid.New().String() + ext
	filepath := filepath.Join(uploadDir, filename)

	// 打开源文件
	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	// 创建目标文件
	dst, err := os.Create(filepath)
	if err != nil {
		return "", err
	}
	defer dst.Close()

	// 复制文件内容
	if _, err := dst.ReadFrom(src); err != nil {
		return "", err
	}

	// 返回相对路径（用于存储在数据库和提供给前端）
	return fmt.Sprintf("/uploads/avatars/%s", filename), nil
}

// DeleteAvatar 删除头像文件
func DeleteAvatar(avatarPath string) error {
	if avatarPath == "" {
		return nil
	}
	fullPath := "." + avatarPath
	return os.Remove(fullPath)
}

// isAllowedImageType 检查是否是允许的图片类型
func isAllowedImageType(contentType string) bool {
	allowed := []string{"image/jpeg", "image/png", "image/webp"}
	contentType = strings.ToLower(contentType)
	for _, t := range allowed {
		if t == contentType {
			return true
		}
	}
	return false
}

