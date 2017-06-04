insulate('onarum', function()
  insulate('when package is not existed', function()
    it('should throw error', function()
      assert.is_error(function()
        require('onarum')
      end, 'missing package file')
    end)
  end)

  insulate('when circular referrence', function()
    it('should output warning', function()
      _G.arg = { 'spec/fixtures/circular-referrence.lua' }
      require('onarum')
    end)
  end)

  it('should bundle file', function()
    _G.arg = { 'spec/fixtures/package.lua' }
    local actual = require('onarum')
    local bundle = io.open('spec/fixtures/bundle.lua')
    local expect = bundle:read('*a')
    bundle:close()
    assert.is_equal(expect, actual)
  end)
end)
