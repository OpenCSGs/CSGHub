package renderHandlers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/mock"
	mockRenderBase "opencsg.com/portal/_mocks/opencsg.com/portal/handlers/render"
	"opencsg.com/portal/pkg/types"
)

func TestSkillHandlerImpl_List(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "skills_index", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/skills", nil)
	ctx.Request = req

	handler := &SkillHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "skills",
			renderBaseInstance: mockBase,
		},
	}

	handler.List(ctx)
}

func TestSkillHandlerImpl_Detail(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "skills_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["skillName"] == "test-skill" &&
				data["actionName"] == "show" &&
				data["defaultTab"] == "summary"
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	// Mock route parameters in Gin context
	ctx.Params = gin.Params{
		{Key: "namespace", Value: "test-namespace"},
		{Key: "skill_name", Value: "test-skill"},
	}

	req, _ := http.NewRequest("GET", "/skills/test-namespace/test-skill", nil)
	ctx.Request = req

	handler := &SkillHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "skills",
			renderBaseInstance: mockBase,
		},
	}

	handler.Detail(ctx)
}

func TestSkillHandlerImpl_New(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "skills_new", mock.MatchedBy(func(data map[string]interface{}) bool {
			licenses, ok := data["licenses"].(string)
			return ok && licenses == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/skills/new", nil)
	ctx.Request = req

	handler := &SkillHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "skills",
			renderBaseInstance: mockBase,
		},
	}

	handler.New(ctx)
}
