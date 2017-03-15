assert(arg and #arg == 1, 'missing package file')

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
bin = bin == '' and '.' or bin

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
LI.inspect(ast, tkl, src, function(msg)
  assert(not msg:match('warning'), msg)
end)

local prelude = readfile(bin .. '/src/prelude.lua')
local header = '\npackage.preload[\'%s\'] = function()\n'
local footer = '\nend\n'
local modname
local chunks = { prelude }
for _, info in pairs(LI.package_loaded) do
  path = info[2].nocollect.source:gsub('^@', '')
  modname = path:gsub('^%./', ''):gsub('/', '.'):gsub('%.lua$', '')
  chunks[#chunks + 1] = header:format(modname)
  chunks[#chunks + 1] = readfile(path)
  chunks[#chunks + 1] = footer
end

local bundle = table.concat(chunks)
io.stdout:write(bundle)
return bundle
