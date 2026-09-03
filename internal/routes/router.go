package routes

import (
	"html/template"
	"io/fs"
	"log"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"runtime/debug"
	"strings"

	"github.com/gin-contrib/multitemplate"
	"github.com/gin-gonic/gin"
	"opencsg.com/portal/config"
	"opencsg.com/portal/frontend"
	frontendHandlers "opencsg.com/portal/internal/handlers/frontend"
	renderHandlers "opencsg.com/portal/internal/handlers/render"
	"opencsg.com/portal/internal/middleware"
	"opencsg.com/portal/internal/svc"
	"opencsg.com/portal/pkg/server"
	"opencsg.com/portal/pkg/types"
)

type HandlersRegistry struct {
	FrontendHandlers *frontendHandlers.FrontendHandlerRegistry
	RenderHandler    *renderHandlers.RenderHandlerRegistry
	// adminHandlers    *adminHandlers.AdminHandlerRegistry
	Config *config.Config
}

func Initialize(svcCtx *svc.ServiceContext) (*gin.Engine, error) {
	g := gin.New()
	_ = g.SetTrustedProxies(nil)

	csghubServer, err := server.NewServer(svcCtx.Config)
	if err != nil {
		log.Fatalf("failed to create server: %v", err)
	}

	writer := os.Stdout
	if svcCtx.Config.AppEnv == "development" {
		logFilePath := "./log/app.log"
		err = os.MkdirAll(filepath.Dir(logFilePath), os.ModePerm)
		if err != nil {
			log.Fatalf("Failed to create directory: %v", err)
		}

		f, err := os.OpenFile(logFilePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0666)
		if err != nil {
			log.Fatalf("Can not open log file：%v", err)
		}
		writer = f
	}

	lh := slog.NewJSONHandler(writer, &slog.HandlerOptions{
		AddSource: false,
		Level:     slog.LevelInfo,
	})
	l := slog.New(lh)

	slog.SetDefault(l)

	g.Use(gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		if err, ok := recovered.(string); ok {
			stackTrace := string(debug.Stack())
			// use slog track error and backtrace
			slog.Error("App Error", "error", err, "stack", stackTrace)
		}
		c.AbortWithStatus(http.StatusInternalServerError)
	}))
	g.Use(middleware.Instance.AuthMiddleware(csghubServer))
	g.Use(middleware.Instance.CacheControlMiddleware())
	// This will track all request to portal go server
	g.Use(middleware.Instance.Log())

	frontendHandlers, err := frontendHandlers.NewHandlersRegistry(svcCtx)
	if err != nil {
		return nil, err
	}

	renderHandler, err := renderHandlers.NewHandlersRegistry(svcCtx)
	if err != nil {
		return nil, err
	}
	handlersRegistry := &HandlersRegistry{
		FrontendHandlers: frontendHandlers,
		RenderHandler:    renderHandler,
		// AdminHandlers:    adminHandlers.NewHandlersRegistry(svcCtx),
		Config: svcCtx.Config,
	}

	g.HTMLRender = createRender()
	setupStaticRouter(g)
	setupApiRouter(g, handlersRegistry)
	setupViewsRouter(g, handlersRegistry)
	setupNotFoundRouter(g)
	return g, nil
}

// register global const
func injectConfig(config types.GlobalConfig) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("Config", config)
		c.Next()
	}
}

func createRender() multitemplate.Renderer {
	viewsFS, err := fs.Sub(frontend.Dist, "dist/src/views")
	if err != nil {
		panic(err)
	}

	r := multitemplate.NewRenderer()

	layouts := []string{
		"layouts/base.html",
		"layouts/navbar.html",
		"layouts/footer.html",
	}

	pages := map[string]string{
		"errors_404":          "errors/404.html",
		"errors_401":          "errors/unauthorized.html",
		"errors_login_failed": "errors/login_failed.html",
		"errors_server_error": "errors/server_error.html",

		"index":                          "home/index.html",
		"models_index":                   "models/index.html",
		"models_show":                    "models/show.html",
		"models_new":                     "models/new.html",
		"datasets_index":                 "datasets/index.html",
		"datasets_show":                  "datasets/show.html",
		"datasets_new":                   "datasets/new.html",
		"codes_index":                    "codes/index.html",
		"codes_show":                     "codes/show.html",
		"codes_new":                      "codes/new.html",
		"skills_index":                   "skills/index.html",
		"skills_show":                    "skills/show.html",
		"skills_new":                     "skills/new.html",
		"spaces_index":                   "spaces/index.html",
		"spaces_show":                    "spaces/show.html",
		"spaces_new":                     "spaces/new.html",
		"endpoints_show":                 "endpoints/show.html",
		"endpoints_new":                  "endpoints/new.html",
		"finetunes_show":                 "finetunes/show.html",
		"finetunes_new":                  "finetunes/new.html",
		"mcp_servers_index":              "mcp_servers/index.html",
		"mcp_servers_show":               "mcp_servers/show.html",
		"mcp_servers_new":                "mcp_servers/new.html",
		"mcp_servers_tools":              "mcp_servers/tools.html",
		"mcp_servers_deploy":             "mcp_servers/deploy.html",
		"resource_console_index":         "resource-console/index.html",
		"organizations_show":             "organizations/show.html",
		"organizations_new":              "organizations/new.html",
		"organizations_settings":         "organizations/settings.html",
		"collections_index":              "collections/index.html",
		"collections_show":               "collections/show.html",
		"collections_new":                "collections/new.html",
		"notebooks_show":                 "notebooks/show.html",
		"notebooks_new":                  "notebooks/new.html",
		"profile":                        "profile/profile.html",
		"profile_likes":                  "profile/likes.html",
		"settings_profile":               "settings/profile.html",
		"settings_access_token":          "settings/access_token.html",
		"settings_api_keys":              "settings/api_keys.html",
		"settings_starship_access_token": "settings/starship_access_token.html",
		"settings_sync_access_token":     "settings/sync_access_token.html",
		"settings_ssh_keys":              "settings/ssh_keys.html",
		"prompts_index":                  "prompts/index.html",
		"evaluations_new":                "evaluations/new.html",
		"evaluations_show":               "evaluations/show.html",
	}

	for name, page := range pages {
		files := make([]string, len(layouts)+1)
		copy(files, layouts)
		files[len(layouts)] = page

		tmpl, err := template.ParseFS(viewsFS, files...)
		if err != nil {
			panic(err)
		}
		r.Add(name, tmpl)
	}

	adminLayouts := []string{
		"admin/layouts/base.html",
	}

	adminPages := map[string]string{
		"admin_index": "admin/index.html",
	}

	for name, page := range adminPages {
		files := make([]string, len(adminLayouts)+1)
		copy(files, adminLayouts)
		files[len(adminLayouts)] = page

		tmpl, err := template.ParseFS(viewsFS, files...)
		if err != nil {
			panic(err)
		}
		r.Add(name, tmpl)
	}

	datapipelinesLayouts := []string{
		"datapipelines/layouts/base.html",
		"layouts/navbar.html",
		"layouts/footer.html",
	}

	datapipelinesPages := map[string]string{
		"datapipelines_index": "datapipelines/index.html",
	}

	for name, page := range datapipelinesPages {
		files := make([]string, len(datapipelinesLayouts)+1)
		copy(files, datapipelinesLayouts)
		files[len(datapipelinesLayouts)] = page

		tmpl, err := template.ParseFS(viewsFS, files...)
		if err != nil {
			panic(err)
		}
		r.Add(name, tmpl)
	}

	// admin new version
	adminNextLayouts := "admin/admin_next.html"
	tmpl, err := template.ParseFS(viewsFS, adminNextLayouts)
	if err != nil {
		panic(err)
	}
	r.Add("admin_next", tmpl)

	return r
}

func setupViewsRouter(engine *gin.Engine, handlersRegistry *HandlersRegistry) {
	var globalConfig = types.GlobalConfig{
		ServerBaseUrl: handlersRegistry.Config.StarhubServer.BaseURL,
		OnPremise:     handlersRegistry.Config.OnPremise,
		EnableHttps:   handlersRegistry.Config.EnableHttps,
		EnabledMenus:  handlersRegistry.Config.EnabledMenus,
	}
	engine.Use(injectConfig(globalConfig))

	registerErrorRoutes(engine, handlersRegistry)
	registerHomeRoutes(engine, handlersRegistry)
	registerModelRoutes(engine, handlersRegistry)
	registerDatasetRoutes(engine, handlersRegistry)
	registerCodeRoutes(engine, handlersRegistry)
	registerSkillRoutes(engine, handlersRegistry)
	registerSpaceRoutes(engine, handlersRegistry)
	registerEndpointRoutes(engine, handlersRegistry)
	registerNotebookRoutes(engine, handlersRegistry)
	registerFinetuneRoutes(engine, handlersRegistry)
	registerMcpServerRoutes(engine, handlersRegistry)
	registerSessionsRoutes(engine, handlersRegistry)
	registerOrganizationRoutes(engine, handlersRegistry)
	registerCollectionRoutes(engine, handlersRegistry)
	registerProfileRoutes(engine, handlersRegistry)
	registerSettingRoutes(engine, handlersRegistry)
	registerResourceConsoleRoutes(engine, handlersRegistry)
	registerAdminRoutes(engine, handlersRegistry)
	registerPromptsRoutes(engine, handlersRegistry)
	registerEvaluationRoutes(engine, handlersRegistry)
	registerDatapipelinesRoutes(engine, handlersRegistry)
}

func setupStaticRouter(engine *gin.Engine) {
	dist, _ := fs.Sub(frontend.Dist, "dist")
	imageFolder, _ := fs.Sub(frontend.Dist, "dist/images")
	fileServer := http.FileServer(http.FS(dist))

	engine.Use(func(c *gin.Context) {
		if strings.HasPrefix(c.Request.URL.Path, "/assets") {
			filePath := strings.TrimPrefix(c.Request.URL.Path, "/")
			if _, err := fs.Stat(dist, filePath); os.IsNotExist(err) {
				// Serve index.html when the file doesn't exist
				c.Request.URL.Path = "/"
			}
			fileServer.ServeHTTP(c.Writer, c.Request)
			c.Abort()
		}
	})

	engine.StaticFS("/images", http.FS(imageFolder))
}

func setupApiRouter(g *gin.Engine, handlersRegistry *HandlersRegistry) {
	internal_api := g.Group("/internal_api")

	internal_api.GET("/ping", handlersRegistry.FrontendHandlers.PingHandler.Ping)
	internal_api.PUT("/users/jwt_token", handlersRegistry.FrontendHandlers.TokenHandler.RefreshToken)
	internal_api.POST("/upload", middleware.Instance.ApiCheckCurrentUser(), handlersRegistry.FrontendHandlers.UploadHandler.Create)
	internal_api.POST("/private_upload", middleware.Instance.ApiCheckCurrentUser(), handlersRegistry.FrontendHandlers.UploadHandler.PrivateCreate)
	internal_api.GET("/oss_temp_url", middleware.Instance.ApiCheckCurrentUser(), handlersRegistry.FrontendHandlers.UploadHandler.GetUrlByObjectKey)

	resolve_group := g.Group("")
	resolve_group.GET("/:repo_type/:namespace/:name/resolve/:branch/*path", handlersRegistry.FrontendHandlers.ResolveHandler.Resolve)

	locale_group := g.Group("")
	locale_group.GET("/zh/settings/locale", handlersRegistry.FrontendHandlers.SettingsHandler.SetZhLocale)
	locale_group.GET("/en/settings/locale", handlersRegistry.FrontendHandlers.SettingsHandler.SetEnLocale)
	locale_group.GET("/zhHant/settings/locale", handlersRegistry.FrontendHandlers.SettingsHandler.SetZhHantLocale)
}

func setupNotFoundRouter(engine *gin.Engine) {
	engine.NoRoute(func(ctx *gin.Context) {
		ctx.Redirect(http.StatusFound, "/errors/not-found")
		ctx.AbortWithStatus(http.StatusNotFound)
	})
}
