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

func TestMcpServerHandlerImpl_List(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "mcp_servers_index", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/mcp_servers", nil)
	ctx.Request = req

	handler := &McpServerHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "mcp_servers",
			renderBaseInstance: mockBase,
		},
	}

	handler.List(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMcpServerHandlerImpl_Detail(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "mcp_servers_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["mcpServerName"] == "test-mcp-server" &&
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
		{Key: "mcp_server_name", Value: "test-mcp-server"},
	}

	req, _ := http.NewRequest("GET", "/mcp_servers/test-namespace/test-mcp-server", nil)
	ctx.Request = req

	handler := &McpServerHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "mcp_servers",
			renderBaseInstance: mockBase,
		},
	}

	handler.Detail(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMcpServerHandlerImpl_Tools(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "mcp_servers_tools", mock.Anything).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/mcp_servers/tools", nil)
	ctx.Request = req

	handler := &McpServerHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "mcp_servers",
			renderBaseInstance: mockBase,
		},
	}

	handler.Tools(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMcpServerHandlerImpl_Schema(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "mcp_servers_show", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["mcpServerName"] == "test-mcp-server" &&
				data["actionName"] == "schema" &&
				data["defaultTab"] == "schema"
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	// Mock route parameters in Gin context
	ctx.Params = gin.Params{
		{Key: "namespace", Value: "test-namespace"},
		{Key: "mcp_server_name", Value: "test-mcp-server"},
	}

	req, _ := http.NewRequest("GET", "/mcp_servers/test-namespace/test-mcp-server/schema", nil)
	ctx.Request = req

	handler := &McpServerHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "mcp_servers",
			renderBaseInstance: mockBase,
		},
	}

	handler.Schema(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMcpServerHandlerImpl_Deploy(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "mcp_servers_deploy", mock.MatchedBy(func(data map[string]interface{}) bool {
			return data["namespace"] == "test-namespace" &&
				data["mcpServerName"] == "test-mcp-server" &&
				data["licenses"] == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	// Mock route parameters in Gin context
	ctx.Params = gin.Params{
		{Key: "namespace", Value: "test-namespace"},
		{Key: "mcp_server_name", Value: "test-mcp-server"},
	}

	req, _ := http.NewRequest("GET", "/mcp_servers/test-namespace/test-mcp-server/deploy", nil)
	ctx.Request = req

	handler := &McpServerHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "mcp_servers",
			renderBaseInstance: mockBase,
		},
	}

	handler.Deploy(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMcpServerHandlerImpl_New(t *testing.T) {
	mockBase := mockRenderBase.NewMockRenderBase(t)

	mockBase.EXPECT().
		RenderTemplate(mock.Anything, "mcp_servers_new", mock.MatchedBy(func(data map[string]interface{}) bool {
			licenses, ok := data["licenses"].(string)
			return ok && licenses == DefaultLicensesJSON
		})).
		Return()

	w := httptest.NewRecorder()
	ctx, _ := gin.CreateTestContext(w)
	ctx.Set("Config", types.GlobalConfig{})

	req, _ := http.NewRequest("GET", "/mcp_servers/new", nil)
	ctx.Request = req

	handler := &McpServerHandlerImpl{
		BaseHandlerImpl{
			resourceType:       "mcp_servers",
			renderBaseInstance: mockBase,
		},
	}

	handler.New(ctx)

	assert.Equal(t, http.StatusOK, w.Code)
}
