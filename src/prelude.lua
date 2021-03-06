package = package or {}
package.loaded = package.loaded or {
  _G = _G,
  coroutine = coroutine,
  debug = debug,
  io = io,
  math = math,
  os = os,
  package = package,
  string = string,
  table = table
}
package.preload = package.preload or {}

require = require or function(modname)
  if package.loaded[modname] == nil then
    assert(package.preload[modname], ("module '%s' not found"):format(modname))
    local mod = package.preload[modname]()
    package.loaded[modname] = mod == nil or mod
  end
  return package.loaded[modname]
end
