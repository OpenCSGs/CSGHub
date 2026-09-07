package renderHandlers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	mockRenderBase "opencsg.com/portal/_mocks/opencsg.com/portal/handlers/render"
	"opencsg.com/portal/pkg/types"
)

func TestSpaceHandlerImpl_List(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "spaces_index", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/spaces", nil)
	ctx.Request = req

	handler := &SpaceHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "spaces",
			renderBaseInstance: mockBase,
		},
	}

	handler.List(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestSpaceHandlerImpl_Detail(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "spaces_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["spaceName"] == "test-space" &&
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
		{Key: "space_name", Value: "test-space"},
	}

	req, _ := http.NewRequest("GET", "/spaces/test-namespace/test-space", nil)
	ctx.Request = req

	handler := &SpaceHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "spaces",
			renderBaseInstance: mockBase,
		},
	}

	handler.Detail(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestSpaceHandlerImpl_New(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "spaces_new", mock.MatchedBy(func(data map[string]interface{}) bool {
			licenses, ok := data["licenses"].(string)
			return ok && licenses == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/spaces/new", nil)
	ctx.Request = req

	handler := &SpaceHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "spaces",
			renderBaseInstance: mockBase,
		},
	}

	handler.New(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}
