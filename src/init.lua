assert(arg and #arg >= 1, 'missing package file')

local function readfile(filename)
  local file = assert(io.open(filename))
  local source = assert(file:read('*a'))
  assert(file:close())
  return source
end

local bin = arg and arg[0] or ''
bin = bin:gsub('[/\\]?[^/\\]+$', ''):gsub('/bin$', '')
bin = (bin == '') and '.' or bin

local base = arg[2] or ''

package.path = table.concat({
  bin .. '/lib/lua-inspect/lib/?.lua;',
  bin .. '/lib/lua-inspect/metalualib/?.lua;',
  package.path
})

local LA = require('luainspect.ast')
local path = arg[1]
local source = readfile(path)
local ast, err, row, col = LA.ast_from_string(source, path)
assert(ast, table.concat({ err, row, col }, '\n'))
local tokenList = LA.ast_to_tokenlist(ast, source)

local LI = require('luainspect.init')
local warnings = {}
LI.inspect(ast, tokenList, source, function(message)
  if message:find('warning') then
    warnings[#warnings + 1] = message
  end
end)
assert(#warnings == 0, table.concat(warnings, '\n'))

local prelude = readfile(bin .. '/src/prelude.lua')
local header = "\npackage.preload['%s'] = function()\n"
local footer = '\nend\n'
local modname
local chunks = { prelude }
for _, info in pairs(LI.package_loaded) do
  path = info[2].nocollect.source:gsub('^@', '')
  modname = path:gsub(base, ''):gsub('^%./', ''):gsub('^/', ''):gsub('/', '.')
    :gsub('%.lua$', '')
  chunks[#chunks + 1] = header:format(modname)
  chunks[#chunks + 1] = readfile(path)
  chunks[#chunks + 1] = footer
end

local bundle = table.concat(chunks)
io.stdout:write(bundle)
return bundle
