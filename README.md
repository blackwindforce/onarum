# Onarum

[![Build Status](https://travis-ci.org/blackwindforce/onarum.svg?branch=master)](https://travis-ci.org/blackwindforce/onarum)
[![Coverage Status](https://coveralls.io/repos/github/blackwindforce/onarum/badge.svg?branch=master)](https://coveralls.io/github/blackwindforce/onarum?branch=master)

## Prerequisite

* [Lua 5.1](https://www.lua.org/)

## Installation

```sh
$ git clone git@github.com:blackwindforce/onarum.git
$ cd onarum
$ git submodule update --init
```

## Usage

**Note: `onarum` CAN NOT use as a system executable due to `luarocks` does not
support `git submodule`, you MUST use `onarum` under `/bin` instead.**

```sh
$ ./bin/onarum ./spec/fixtures/package.lua
```

## Example

### package.lua

Specify your module dependencies.

```lua
require('spec.fixtures.add')
```

### add.lua

Write your modules as usual.

```lua
return function(x)
  return function(y)
    return x + y
  end
end
```

### bundle.lua

Preload your modules in bundle.

```lua
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

package.preload['spec.fixtures.add'] = function()
return function(x)
  return function(y)
    return x + y
  end
end

end
```

### init.lua

Use your modules as usual.

```lua
print(require('spec.fixtures.add')(1)(2) == 3)
```

## Testing

```sh
$ luarocks install busted
$ luarocks install luacheck
$ luarocks install luacov
$ luarocks install luacov-console
$ make test
```
