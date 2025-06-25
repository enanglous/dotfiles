require("folder-rules"):setup()

if os.getenv("NVIM") then
require("toggle-pane"):entry("min-preview")
end

Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)
