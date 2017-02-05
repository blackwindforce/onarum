insulate('prelude', function()
  local _package = _G.package
  local _require = _G.require

  insulate('when require support natively', function()
    it('should not polyfill', function()
      dofile('src/prelude.lua')
      assert.same(_package, _G.package)
      assert.same(_require, _G.require)
    end)
  end)

  insulate('when require not support natively', function()
    local package_
    local require_
    local require__

    before_each(function()
      _G.package = false
      _G.require = false
      dofile('src/prelude.lua')
      package_ = _G.package
      require_ = _G.require
      require__ = function(...)
        _G.package = package_
        local mod = require_(...)
        _G.package = _package
        return mod
      end
      _G.package = _package
      _G.require = _require
    end)

    it('should polyfill', function()
      assert.not_same(_package, package_)
      assert.not_same(_require, require_)
      assert.is_table(package_)
      assert.is_table(package_.loaded)
      assert.is_table(package_.preload)
      assert.is_function(require_)
    end)

    it('should require globals', function()
      assert.same(_G, require__('_G'))
      assert.same(coroutine, require__('coroutine'))
      assert.same(debug, require__('debug'))
      assert.same(io, require__('io'))
      assert.same(math, require__('math'))
      assert.same(os, require__('os'))
      assert.same(package_, require__('package'))
      assert.same(string, require__('string'))
      assert.same(table, require__('table'))
    end)

    it('should not require globals', function()
      assert.has_error(function() require__('_VERSION') end)
    end)

    it('should require once', function()
      local exp = {}
      package_.preload.foo = spy.new(function() return exp end)
      local foo = require__('foo')
      assert.same(exp, package_.loaded.foo)
      assert.same(exp, foo)
      require__('foo')
      assert.spy(package_.preload.foo).called_at_most(1)
    end)

    it('should require true', function()
      package_.preload.foo = function() return end
      local foo = require__('foo')
      assert.is_true(foo)
    end)
  end)
end)
