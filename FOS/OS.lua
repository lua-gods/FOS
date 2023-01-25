local os = {}
local relative_path = ""
local table_path = {...}
table.remove(table_path,#table_path)
for id, index in pairs(table_path) do
   relative_path = relative_path..index
   if id ~= #table_path then
      relative_path = relative_path.."."
   end
end
local reg = require(relative_path..".registry")
reg.root_path = relative_path
FOS_RELATIVE_PATH = relative_path

for key, value in pairs(reg.services) do
   require(FOS_RELATIVE_PATH..".services."..value)
end

return os