-- WezTerm Configuration
-- Simple, fast, professional terminal setup

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ============================================================================
-- APPEARANCE
-- ============================================================================

-- Theme: Dark and minimal
config.color_scheme = "Tokyo Night Storm"

-- Font configuration
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0
config.adjust_window_size_when_changing_font_size = false

-- Window appearance
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}

-- Tab bar styling - Fancy tab bar with fixed font size
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

-- Window frame with fixed 18px font for tab bar
config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 18.0,
	active_titlebar_bg = "#1a1b26",
	inactive_titlebar_bg = "#1a1b26",
}

-- Colors for tab bar
config.colors = {
	tab_bar = {
		background = "#1a1b26",
		active_tab = {
			bg_color = "#7aa2f7",
			fg_color = "#1a1b26",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#24283b",
			fg_color = "#787c99",
		},
		inactive_tab_hover = {
			bg_color = "#414868",
			fg_color = "#c0caf5",
		},
	},
}

-- ============================================================================
-- TAB BAR WITH CWD
-- ============================================================================

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#24283b"
	local foreground = "#787c99"

	if tab.is_active then
		background = "#7aa2f7"
		foreground = "#1a1b26"
	elseif hover then
		background = "#414868"
		foreground = "#c0caf5"
	end

	-- Get the current working directory
	local cwd = tab.active_pane.current_working_dir
	local cwd_path = ""
	if cwd then
		cwd_path = cwd.file_path or ""
		-- Show only the last directory name
		cwd_path = cwd_path:match("([^/]+)/?$") or cwd_path
	end

	-- Add padding around tab title
	local title = string.format(" %d %s ", tab.tab_index + 1, cwd_path)

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

-- ============================================================================
-- STATUS BAR WITH SYSTEM STATS
-- ============================================================================

wezterm.on("update-status", function(window, pane)
	-- Get system stats
	local cpu = ""
	local ram = ""
	local net = ""

	-- CPU usage (macOS) - accurate system-wide percentage
	local cpu_success, cpu_stdout = wezterm.run_child_process({
		"sh",
		"-c",
		"top -l 2 | grep -E '^CPU' | tail -1 | awk '{print $3}' | sed 's/%//'",
	})
	if cpu_success then
		cpu = string.format("CPU: %.0f%%", tonumber(cpu_stdout) or 0)
	end

	-- RAM usage (macOS)
	local ram_success, ram_stdout, ram_stderr = wezterm.run_child_process({
		"sh",
		"-c",
		"ps -caxm -orss= | awk '{ sum += $1 } END { print sum / 1024 / 1024 }'",
	})
	if ram_success then
		ram = string.format("RAM: %.1fGB", tonumber(ram_stdout) or 0)
	end

	-- Network speed (simplified - shows if connected)
	local net_success, net_stdout, net_stderr = wezterm.run_child_process({
		"sh",
		"-c",
		"ifstat -i en0 -b 0.1 1 | tail -n 1 | awk '{print $1, $2}'",
	})
	if net_success and net_stdout ~= "" then
		local down, up = net_stdout:match("(%S+)%s+(%S+)")
		if down and up then
			net = string.format("↓%.0fKB/s ↑%.0fKB/s", tonumber(down) or 0, tonumber(up) or 0)
		else
			net = "NET: --"
		end
	else
		net = "NET: --"
	end

	-- Format status bar
	local stats = string.format("%s  |  %s  |  %s", cpu, ram, net)

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#7aa2f7" } },
		{ Text = " " .. stats .. " " },
	}))
end)

-- ============================================================================
-- KEYBINDINGS
-- ============================================================================

config.keys = {
	-- Tab management
	{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = true }) },

	-- Navigate to specific tabs
	{ key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "CMD", action = wezterm.action.ActivateTab(8) },

	-- Font size controls
	{ key = "+", mods = "CMD", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },

	-- Split panes with directional control
	{ key = "j", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Down" }) },
	{ key = "k", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Up" }) },
	{ key = "h", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Left" }) },
	{ key = "l", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Right" }) },

	-- Close current pane
	{ key = "w", mods = "CMD|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

	-- Helix-style modal editing mode (Leader key: CMD+Space)
	{
		key = "Space",
		mods = "CMD",
		action = wezterm.action.ActivateKeyTable({
			name = "helix_mode",
			one_shot = false,
			timeout_milliseconds = 5000,
		}),
	},

	-- Copy mode with Helix keybindings
	{
		key = "c",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateCopyMode,
	},

	-- Project launcher (Cmd+P)
	{
		key = "p",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			-- Get list of directories in ~/dev
			local success, stdout, stderr = wezterm.run_child_process({
				"sh",
				"-c",
				"find ~/dev -maxdepth 1 -type d ! -path ~/dev -exec basename {} \\;",
			})

			if success then
				local projects = {}
				for project in stdout:gmatch("[^\r\n]+") do
					table.insert(projects, { label = project })
				end

				-- Show project picker
				window:perform_action(
					wezterm.action.InputSelector({
						title = "Select Project",
						choices = projects,
						fuzzy = true,
						action = wezterm.action_callback(function(window, pane, id, label)
							if label then
								-- Spawn new tab in selected project directory
								window:perform_action(
									wezterm.action.SpawnCommandInNewTab({
										cwd = wezterm.home_dir .. "/dev/" .. label,
									}),
									pane
								)
							end
						end),
					}),
					pane
				)
			end
		end),
	},
}

-- Helix-style modal keybindings
config.key_tables = {
	helix_mode = {
		-- Window/Pane management (like Helix's space mode)
		{ key = "v", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "s", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "x", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

		-- Navigation (vim-style)
		{ key = "h", action = wezterm.action.ActivatePaneDirection("Left") },
		{ key = "j", action = wezterm.action.ActivatePaneDirection("Down") },
		{ key = "k", action = wezterm.action.ActivatePaneDirection("Up") },
		{ key = "l", action = wezterm.action.ActivatePaneDirection("Right") },

		-- Resize panes
		{ key = "H", mods = "SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
		{ key = "J", mods = "SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
		{ key = "K", mods = "SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
		{ key = "L", mods = "SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },

		-- Exit modal mode
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},

	copy_mode = {
		-- Helix-style movement in copy mode
		{ key = "h", mods = "NONE", action = wezterm.action.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = wezterm.action.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = wezterm.action.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = wezterm.action.CopyMode("MoveRight") },

		-- Word movement
		{ key = "w", mods = "NONE", action = wezterm.action.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = wezterm.action.CopyMode("MoveBackwardWord") },

		-- Selection
		{ key = "v", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "V", mods = "SHIFT", action = wezterm.action.CopyMode({ SetSelectionMode = "Line" }) },

		-- Copy and exit
		{ key = "y", mods = "NONE", action = wezterm.action.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },

		-- Exit copy mode
		{ key = "Escape", mods = "NONE", action = wezterm.action.CopyMode("Close") },
	},
}

-- ============================================================================
-- URL DETECTION AND MOUSE BINDINGS
-- ============================================================================

-- Detect URLs and file paths
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Mouse bindings for clickable URLs
config.mouse_bindings = {
	-- Click to open URLs
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Cmd+Click for alternate action (if you want both options)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- ============================================================================
-- PERFORMANCE
-- ============================================================================

config.max_fps = 120
config.animation_fps = 60
config.cursor_blink_rate = 500

-- Enable shell integration for better CWD tracking
config.set_environment_variables = {
	TERM_PROGRAM = "WezTerm",
}

return config
