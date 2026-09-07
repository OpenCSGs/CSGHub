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

func TestFinetuneHandlerImpl_List(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "finetunes_index", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/finetunes", nil)
	ctx.Request = req

	handler := &FinetuneHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "finetunes",
			renderBaseInstance: mockBase,
		},
	}

	handler.List(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestFinetuneHandlerImpl_Detail(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "finetunes_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["modelName"] == "test-model" &&
				data["finetuneId"] == "test-finetune-id" &&
				data["finetuneName"] == "test-finetune-name" &&
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
		{Key: "model_name", Value: "test-model"},
		{Key: "finetune_id", Value: "test-finetune-id"},
		{Key: "finetune_name", Value: "test-finetune-name"},
	}

	req, _ := http.NewRequest("GET", "/finetunes/test-namespace/test-model/test-finetune-id/test-finetune-name", nil)
	ctx.Request = req

	handler := &FinetuneHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "finetunes",
			renderBaseInstance: mockBase,
		},
	}

	handler.Detail(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestFinetuneHandlerImpl_New(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "finetunes_new", mock.MatchedBy(func(data map[string]interface{}) bool {
			licenses, ok := data["licenses"].(string)
			return ok && licenses == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/finetunes/new", nil)
	ctx.Request = req

	handler := &FinetuneHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "finetunes",
			renderBaseInstance: mockBase,
		},
	}

	handler.New(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}
