# Menu Configuration

## Feature: Enable/Disable Top-Level Menu Items

This feature allows administrators to control which top-level menu items appear in the CSGHub portal navigation bar through environment variable configuration.

## Configuration

Add the following environment variable to your `.env` file:

```bash
CSGHUB_PORTAL_ENABLED_MENUS=models,datasets,mcp,skills,spaces,codes,collections,prompts
```

### Available Menu Items

The following menu items can be enabled or disabled:

- `models` - Models repository
- `datasets` - Datasets repository
- `mcp` - MCP Servers (with sub-items: MCP Servers and MCP Tools)
- `skills` - Skills repository
- `spaces` - Application Spaces
- `codes` - Code repository
- `collections` - Collections
- `prompts` - Prompt Library

### Default Behavior

If `CSGHUB_PORTAL_ENABLED_MENUS` is not set, all menu items are enabled by default.

## Examples

### Enable Only Models and Datasets

```bash
CSGHUB_PORTAL_ENABLED_MENUS=models,datasets
```

This will show only the "Models" and "Datasets" menu items in the navigation bar.

### Enable Core Features Only

```bash
CSGHUB_PORTAL_ENABLED_MENUS=models,datasets,spaces,codes
```

This will hide MCP, Skills, Collections, and Prompts from the menu.

### SaaS vs On-Premise

For SaaS deployments, you might want to limit certain features:

```bash
CSGHUB_PORTAL_ON_PREMISE=false
CSGHUB_PORTAL_ENABLED_MENUS=models,datasets,spaces
```

For on-premise deployments, you might enable all features:

```bash
CSGHUB_PORTAL_ON_PREMISE=true
CSGHUB_PORTAL_ENABLED_MENUS=models,datasets,mcp,skills,spaces,codes,collections,prompts
```

## Implementation Details

### Backend Changes

1. **config/config.go**: Added `EnabledMenus` field to Config struct
2. **pkg/types/constants.go**: Added `EnabledMenus` field to GlobalConfig
3. **internal/routes/router.go**: Pass EnabledMenus to GlobalConfig
4. **internal/handlers/render/base.go**: Include enabledMenus in template data

### Frontend Changes

1. **Template Files**: Added `ENABLED_MENUS` constant to all base.html templates
   - frontend/src/views/layouts/base.html
   - frontend/src/views/admin/layouts/base.html
   - frontend/src/views/admin/admin_next.html
   - frontend/src/views/datapipelines/layouts/base.html

2. **MenuItems.vue**: Updated to filter menu items based on configuration
   - Added unique `id` field to each menu item
   - Parse `ENABLED_MENUS` from global configuration
   - Filter menu items using Set for O(1) lookup

## Testing

### Manual Testing

1. Set the environment variable:
   ```bash
   export CSGHUB_PORTAL_ENABLED_MENUS=models,datasets
   ```

2. Start the application:
   ```bash
   make run
   ```

3. Open the portal in a browser and verify that only Models and Datasets menus appear

4. Try different combinations:
   ```bash
   # Test with single menu
   export CSGHUB_PORTAL_ENABLED_MENUS=models
   
   # Test with all menus (default)
   export CSGHUB_PORTAL_ENABLED_MENUS=models,datasets,mcp,skills,spaces,codes,collections,prompts
   
   # Test with empty (should show all)
   unset CSGHUB_PORTAL_ENABLED_MENUS
   ```

### Expected Behavior

- Menu items not in the enabled list should not appear in the navigation bar
- The responsive "More" menu should still work correctly for smaller screens
- Submenu items (like MCP sub-items) should appear when their parent is enabled
- Direct URL access to disabled menu pages is still possible (this is navigation-only filtering)

## Notes

- This feature only affects the visibility of menu items in the navigation bar
- Users can still access pages directly via URL even if the menu item is hidden
- For complete feature disabling, additional backend access control is required
- The menu filtering is done on the frontend for better performance
- No database changes are required for this feature

## Troubleshooting

### Menus not appearing after configuration change

1. Restart the backend service to reload environment variables
2. Clear browser cache
3. Verify the environment variable is correctly set: `env | grep ENABLED_MENUS`

### All menus disappear

Check if the environment variable has correct syntax:
- Values should be comma-separated
- No spaces around commas
- Use exact menu IDs (case-sensitive)
- If in doubt, unset the variable to restore defaults

## Future Enhancements

Potential improvements for this feature:

1. Add UI configuration panel for administrators
2. Per-user or per-role menu customization
3. Database-backed configuration instead of environment variables
4. Menu item ordering configuration
5. Backend route access control to enforce menu visibility at API level
