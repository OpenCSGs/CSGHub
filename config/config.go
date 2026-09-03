package config

import (
	"github.com/kelseyhightower/envconfig"
)

type DatabaseDialect string

const (
	DialectPostgres DatabaseDialect = "pg"
	DialectSQLite   DatabaseDialect = "sqlite"
)

type Config struct {
	AppEnv         string `envconfig:"CSGHUB_PORTAL_APP_ENV" default:"development"`
	ServerPort     int    `envconfig:"CSGHUB_PORTAL_SERVER_PORT" default:"8090"`
	SuperUsers     string `envconfig:"CSGHUB_PORTAL_SUPER_USERS" default:""`
	OnPremise      bool   `envconfig:"CSGHUB_PORTAL_ON_PREMISE" default:"true"`
	SensitiveCheck bool   `envconfig:"CSGHUB_PORTAL_SENSITIVE_CHECK" default:"false"`
	EnableHttps    bool   `envconfig:"CSGHUB_PORTAL_ENABLE_HTTPS" default:"true"`
	SignupURL      string `envconfig:"CSGHUB_PORTAL_SIGNUP_URL" default:""`
	LoginURL       string `envconfig:"CSGHUB_PORTAL_LOGIN_URL" default:"http://60.205.228.141:8000/login/oauth/authorize?client_id=4ba65e712c5dabca3e48&response_type=code&redirect_uri=http://localhost:8080/api/v1/callback/casdoor&scope=read&state=casdoor"`
	EnabledMenus   string `envconfig:"CSGHUB_PORTAL_ENABLED_MENUS" default:"models,datasets,mcp,skills,spaces,codes,collections,prompts"`

	StarhubServer struct {
		BaseURL string `envconfig:"CSGHUB_PORTAL_STARHUB_BASE_URL" default:"http://localhost:8080"`
		APIKey  string `envconfig:"CSGHUB_PORTAL_STARHUB_API_KEY" default:"0c11e6e4f2054444374ba3f0b70de4145935a7312289d404814cd5907c6aa93cc65cd35dbf94e04c13a3dedbf51f1694de84240c8acb7238b54a2c3ac8e87c59"`
	}

	Database struct {
		DSN     string          `envconfig:"CSGHUB_PORTAL_DATABASE_DSN" default:"postgresql://postgres:postgres@localhost:5432/starhub_portal?sslmode=disable"`
		Dialect DatabaseDialect `envconfig:"CSGHUB_PORTAL_DATABASE_DIALECT" default:"pg"`
	}

	S3 struct {
		EnableSSL       bool   `envconfig:"CSGHUB_PORTAL_S3_ENABLE_SSL" default:"false"`
		Endpoint        string `envconfig:"CSGHUB_PORTAL_S3_ENDPOINT" default:"localhost:9000"`
		AccessKeyID     string `envconfig:"CSGHUB_PORTAL_S3_ACCESS_KEY_ID" default:""`
		AccessKeySecret string `envconfig:"CSGHUB_PORTAL_S3_ACCESS_KEY_SECRET" default:""`
		Region          string `envconfig:"CSGHUB_PORTAL_S3_REGION" default:""`
		Bucket          string `envconfig:"CSGHUB_PORTAL_S3_BUCKET" default:""`
	}

	PrivateS3 struct {
		EnableSSL       bool   `envconfig:"CSGHUB_PORTAL_PRIVATE_S3_ENABLE_SSL" default:"false"`
		Endpoint        string `envconfig:"CSGHUB_PORTAL_PRIVATE_S3_ENDPOINT" default:"localhost:9000"`
		AccessKeyID     string `envconfig:"CSGHUB_PORTAL_PRIVATE_S3_ACCESS_KEY_ID" default:""`
		AccessKeySecret string `envconfig:"CSGHUB_PORTAL_PRIVATE_S3_ACCESS_KEY_SECRET" default:""`
		Region          string `envconfig:"CSGHUB_PORTAL_PRIVATE_S3_REGION" default:""`
		Bucket          string `envconfig:"CSGHUB_PORTAL_PRIVATE_S3_BUCKET" default:""`
	}
}

func LoadConfig() (*Config, error) {
	config := new(Config)
	err := envconfig.Process("", config)
	if err != nil {
		return nil, err
	}
	return config, nil
}