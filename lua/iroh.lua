local M = {}

local function escape_double_quotes(text)
	local escaped_text = {}
	for _, line in ipairs(text) do
		local escaped_line = line:gsub('"', '\\"')
		table.insert(escaped_text, escaped_line)
	end

	return escaped_text
end

local function trim_indentation(selected_text)
	-- Find the minimum indentation level among all lines
	local min_indent = math.huge
	for _, line in ipairs(selected_text) do
		local indent = line:match("^%s*")
		if indent then
			min_indent = math.min(min_indent, #indent)
		end
	end

	-- Remove the minimum indentation level from each line
	local trimmed_text = {}
	for _, line in ipairs(selected_text) do
		local trimmed_line = line:sub(min_indent + 1)
		table.insert(trimmed_text, trimmed_line)
	end

	return trimmed_text
end

M.setup = function()
	-- nothing
end

M.transform = function()
	local prompt = vim.fn.input("Transform: ")

	if prompt == nil or prompt == "" then
		print("No prompt provided...")
		return
	end

    print("\n")

	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(0)
	local start_pos = vim.api.nvim_buf_get_mark(buf, "<")
	local end_pos = vim.api.nvim_buf_get_mark(buf, ">")
	local selection = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)

	selection = escape_double_quotes(selection)
	selection = trim_indentation(selection)
	selection = table.concat(selection, "\n")

	if selection == nil or selection == "" then
		print("No text selection to transform...")
	end

	local cmd = "claude -p --dangerously-skip-permissions " .. ' "' .. prompt .. '\n' .. selection .. ' \n in file ' .. filename .. '"'
    -- print(cmd .. '\n')

	local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
	local result = assert(handle:read("*a"), "Unable to read the result")

	print(result)
	handle:close()

    vim.cmd("edit")
end

return M
