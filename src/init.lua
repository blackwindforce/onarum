assert(arg and #arg >= 1, 'missing package file')

local function readfile(filename)
  local file = assert(io.open(filename))
  local src = assert(file:read('*a'))
  assert(file:close())
  return src
end

local path = arg[1]
local src = readfile(path)

local bin = arg and arg[0] or ''
bin = bin:gsub('[/\\]?[^/\\]+$', ''):gsub('/bin$', '')
bin = (bin == '') and '.' or bin

local modulePath = arg[2] and arg[2] or ''
modulePath = modulePath:gsub('/', '.')
modulePath = (modulePath ~= '') and modulePath .. '.' or nil

package.path = table.concat({
  bin .. '/lib/lua-inspect/lib/?.lua;',
  bin .. '/lib/lua-inspect/metalualib/?.lua;',
  package.path
})

local LA = require('luainspect.ast')
local ast, err, row, col = LA.ast_from_string(src, path)
assert(ast, table.concat({ err, row, col }, '\n'))
local tkl = LA.ast_to_tokenlist(ast, src)

local LI = require('luainspect.init')
local warnings = {}
LI.inspect(ast, tkl, src, function(msg)
  if msg:find('warning') then
    warnings[#warnings + 1] = msg
  end
end)

if #warnings > 0 then
  local message = table.concat(warnings, '\n')
  io.stderr:write(message..'\n')
  error('erorr happened during compilation')
end

local prelude = readfile(bin .. '/src/prelude.lua')
local header = "\npackage.preload['%s'] = function()\n"
local footer = '\nend\n'
local modname
local chunks = { prelude }
for _, info in pairs(LI.package_loaded) do
  path = info[2].nocollect.source:gsub('^@', '')
  local shortPath = modulePath and path:gsub(modulePath, '') or path
  modname = shortPath:gsub('^%./', ''):gsub('/', '.'):gsub('%.lua$', '')
  chunks[#chunks + 1] = header:format(modname)
  chunks[#chunks + 1] = readfile(path)
  chunks[#chunks + 1] = footer
end

local bundle = table.concat(chunks)
io.stdout:write(bundle)
return bundle
