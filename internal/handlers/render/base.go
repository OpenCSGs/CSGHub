package renderHandlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"opencsg.com/portal/internal/models"
	"opencsg.com/portal/pkg/types"
	"opencsg.com/portal/pkg/utils/jwt"
)

const (
	DEFAULT_META_TITLE       = "OpenCSG 打造中国本土化 Huggingface plus 开源社区 开放传神 OpenCSG  传神社区 官网"
	DEFAULT_META_KEYWORDS    = "开源大模型、算力平台、Huggingface、开源社区、开源社区、数据集、开源代码、算力租赁、英伟达的算力、A800、H800、新质生产力"
	DEFAULT_META_DESCRIPTION = "OpenCSG愿景： 让大模型赋能每一个人,大模型驱动全民，推动技术创新，OpenCSG——平台有各个领域的大模型，提供模型探索体验、推理、训练、部署和应用的一站式服务，共建模型开源社区，发现、学习、定制和分享心仪的模型。"
)

type RenderBase interface {
	RenderTemplate(ctx *gin.Context, templateName string, data map[string]interface{})
}

type RenderBaseImpl struct {
	jwtUtils jwt.JwtUtils
}

func NewRenderBase() RenderBase {
	return &RenderBaseImpl{
		jwtUtils: jwt.NewJwtUtils(),
	}
}

var RenderBaseInstance = NewRenderBase()

func (i *RenderBaseImpl) RenderTemplate(ctx *gin.Context, templateName string, data map[string]interface{}) {
	ctx.HTML(http.StatusOK, templateName, createTemplateData(ctx, data))
}

func createTemplateData(ctx *gin.Context, extraData map[string]interface{}) gin.H {
	config := getConfig(ctx)
	currentUser, isLoggedIn := getCurrentUserInfo(ctx)

	data := gin.H{
		"csghubServer":    config.ServerBaseUrl,
		"onPremise":       config.OnPremise,
		"enableHttps":     config.EnableHttps,
		"enabledMenus":    config.EnabledMenus,
		"currentUser":     currentUser,
		"isLoggedIn":      isLoggedIn,
		"metaTitle":       DEFAULT_META_TITLE,
		"metaKeywords":    DEFAULT_META_KEYWORDS,
		"metaDescription": DEFAULT_META_DESCRIPTION,
	}

	for k, v := range extraData {
		data[k] = v
	}

	return data
}

func getConfig(ctx *gin.Context) types.GlobalConfig {
	return ctx.MustGet("Config").(types.GlobalConfig)
}

func getCurrentUserInfo(ctx *gin.Context) (models.User, bool) {
	var jwtUtils = jwt.NewJwtUtils()
	currentUser := jwtUtils.GetCurrentUser(ctx)
	if currentUser != nil {
		return *currentUser, true
	}
	return models.User{}, false
}
