---purpose: Handles the Themes


---@class UIButton
---@field text string
---@field anchor Vector2
---@field size Vector2
---@field pos Vector2
---@field onPress KattEvent
---@field onRelease KattEvent
local UIButton = {}
UIButton.__index = UIButton

---@class UILabel
---@field text string
---@field anchor Vector2
---@field size Vector2
---@field pos Vector2
local UILabel = {}
UILabel.__index = UILabel


---@class UIPage
---@field elements table
local UIPage = {}
UIPage.__index = UIPage

