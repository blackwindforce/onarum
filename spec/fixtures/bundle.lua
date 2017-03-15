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
  if not package.loaded[modname] then
    local mod = package.preload[modname]()
    package.loaded[modname] = mod == nil or mod
  end
  return package.loaded[modname]
end

package.preload['spec.fixtures.add'] = function()
return function(x)
  return function(y)
    return x + y
  end
end

end
