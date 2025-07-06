local last_char = nil
local last_ending = nil
local valid_endings = { "')", '")', "'", '"', ")", "]", "}", ")}", "]}", "')}", '")}', '("")', "('')" }

local function get_word()
	return vim.fn.expand("<cword>")
end

local function get_line()
	return vim.fn.getline(".")
end

local function has_valid_ending(word)
	for index, value in ipairs(valid_endings) do
		if word:sub(-string.len(value)) == value then
			last_ending = value
			return true
		end
	end
	last_ending = nil
	return false
end

local function word_at_end_line(word, line)
	return line:sub(-string.len(word)) == word
end

local function t(str)
	print(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function smart_semicolon(char)
	word = get_word()
	line = get_line()

	if has_valid_ending(word) then
		last_char = char
	else
		last_char = nil
	end

	if last_char ~= nil and word_at_end_line(word, line) then
		-- Set mark 0 at current position before moving to end of line
		return t("<c-o>m0<c-o>A" .. char)
	else
		return char
	end
end

local function undo_smart_semicolon()
	if last_ending == nil then
		return t("<BS>")
	else
		last_ending = nil
		-- Delete the semicolon at end of line, jump to mark 0, insert semicolon
		return t("<BS><C-o>`0<C-o>i" .. last_char)
	end
end

local function setup()
	_G.smart_semicolon = smart_semicolon
	_G.undo_smart_semicolon = undo_smart_semicolon

	local map = vim.api.nvim_set_keymap
	map("i", ";", "v:lua.smart_semicolon(';')", { noremap = true, expr = true })
	map("i", "<c-h>", "v:lua.undo_smart_semicolon()", { noremap = true, expr = true })
end

return { setup = setup }
