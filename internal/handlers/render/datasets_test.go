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

func TestDatasetHandlerImpl_List(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "datasets_index", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/datasets", nil)
	ctx.Request = req

	handler := &DatasetHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "datasets",
			renderBaseInstance: mockBase,
		},
	}

	handler.List(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDatasetHandlerImpl_Detail(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "datasets_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["datasetName"] == "test-dataset" &&
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
		{Key: "dataset_name", Value: "test-dataset"},
	}

	req, _ := http.NewRequest("GET", "/datasets/test-namespace/test-dataset", nil)
	ctx.Request = req

	handler := &DatasetHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "datasets",
			renderBaseInstance: mockBase,
		},
	}

	handler.Detail(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestDatasetHandlerImpl_New(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "datasets_new", mock.MatchedBy(func(data map[string]interface{}) bool {
			licenses, ok := data["licenses"].(string)
			return ok && licenses == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/datasets/new", nil)
	ctx.Request = req

	handler := &DatasetHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "datasets",
			renderBaseInstance: mockBase,
		},
	}

	handler.New(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}
