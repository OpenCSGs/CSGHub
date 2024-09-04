package renderHandlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"opencsg.com/portal/internal/config"
)

type SessionHandler interface {
	Login(ctx *gin.Context)
	SignUp(ctx *gin.Context)
	Logout(ctx *gin.Context)
}

type SessionHandlerImpl struct{}

func NewSessionHandler() SessionHandler {
	return &SessionHandlerImpl{}
}

func (i *SessionHandlerImpl) Login(ctx *gin.Context) {
	ctx.Redirect(http.StatusFound, config.Env("SIGNUP_URL", "").(string))
}

func (i *SessionHandlerImpl) SignUp(ctx *gin.Context) {
	ctx.Redirect(http.StatusFound, config.Env("LOGIN_URL", "").(string))
}

func (i *SessionHandlerImpl) Logout(ctx *gin.Context) {
	ctx.Redirect(http.StatusFound, "/")
}

func (i *SessionHandlerImpl) Create(ctx *gin.Context) {
	// 调用 jwt token 验证接口获取 userinfos
	ctx.SetCookie("user_token", ctx.Param("jwt"), 3600*24*7, "/", "", false, false)
	ctx.SetCookie("can_change_username", ctx.Param("can_change_username"), 3600*24*7, "/", "", false, false)
	// login_by_server_user_infos 通过 userinfo 创建用户
	// log_in 设置 user session，其他 cookies
}
