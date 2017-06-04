insulate('prelude', function()
  local package_native = _G.package
  local require_native = _G.require

  insulate('when `require` is existed', function()
    it('should not polyfill', function()
      dofile('src/prelude.lua')
      assert.is_equal(package_native, _G.package)
      assert.is_equal(require_native, _G.require)
    end)
  end)

  insulate('when `require` is not existed', function()
    local package_polyfill
    local require_polyfill
    local require_insulate

    before_each(function()
      _G.package = nil
      _G.require = nil
      dofile('src/prelude.lua')
      package_polyfill = _G.package
      require_polyfill = _G.require

      require_insulate = function(...)
        _G.package = package_polyfill
        local mod = require_polyfill(...)
        _G.package = package_native
        return mod
      end

      _G.package = package_native
      _G.require = require_native
    end)

    it('should polyfill', function()
      assert.is_not_equal(package_native, package_polyfill)
      assert.is_not_equal(require_native, require_polyfill)
      assert.is_table(package_polyfill)
      assert.is_table(package_polyfill.loaded)
      assert.is_table(package_polyfill.preload)
      assert.is_function(require_polyfill)
    end)

    it('should throw error', function()
      assert.is_error(function()
        require_insulate('_VERSION')
      end, "module '_VERSION' not found")
      assert.is_error(function()
        require_insulate('')
      end, "module '' not found")
    end)

    it('should require globals', function()
      assert.is_equal(_G, require_insulate('_G'))
      assert.is_equal(coroutine, require_insulate('coroutine'))
      assert.is_equal(debug, require_insulate('debug'))
      assert.is_equal(io, require_insulate('io'))
      assert.is_equal(math, require_insulate('math'))
      assert.is_equal(os, require_insulate('os'))
      assert.is_equal(package_polyfill, require_insulate('package'))
      assert.is_equal(string, require_insulate('string'))
      assert.is_equal(table, require_insulate('table'))
    end)

    it('should require once', function()
      for _, value in ipairs({ false, function() end, 0, '', {} }) do
        local key = type(value):upper()
        package_polyfill.preload[key] = spy(function()
          return value
        end)
        assert.is_equal(value, require_insulate(key))
        assert.is_equal(value, package_polyfill.loaded[key])

        require_insulate(key)
        assert.spy(package_polyfill.preload[key]).is_called(1)
      end
    end)

    it('should require true', function()
      package_polyfill.preload.foo = spy(function() end)
      assert.is_true(require_insulate('foo'))
    end)
  end)
end)
