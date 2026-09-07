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

func TestNotebookHandlerImpl_List(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "notebooks_index", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/notebooks", nil)
	ctx.Request = req

	handler := &NotebookHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "notebooks",
			renderBaseInstance: mockBase,
		},
	}

	handler.List(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestNotebookHandlerImpl_Show(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "notebooks_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["notebookId"] == "test-notebook-id" &&
				data["path"] == "test/path" &&
				data["isSmallFooter"] == true
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	// Mock route parameters in Gin context
	ctx.Params = gin.Params{
		{Key: "notebook_id", Value: "test-notebook-id"},
		{Key: "path", Value: "/test/path"},
	}

	req, _ := http.NewRequest("GET", "/notebooks/test-notebook-id/test/path", nil)
	ctx.Request = req

	handler := &NotebookHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "notebooks",
			isSmallFooter:      true,
			renderBaseInstance: mockBase,
		},
	}

	handler.Show(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestNotebookHandlerImpl_New(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "notebooks_new", mock.MatchedBy(func(data map[string]interface{}) bool {
			licenses, ok := data["licenses"].(string)
			return ok && licenses == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/notebooks/new", nil)
	ctx.Request = req

	handler := &NotebookHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "notebooks",
			renderBaseInstance: mockBase,
		},
	}

	handler.New(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}
