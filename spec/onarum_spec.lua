insulate('onarum', function()
  insulate('when package file not exist', function()
    it('should throw error', function()
      _G.arg = {}
      assert.error_matches(function()
        dofile('onarum.lua')
      end, 'missing package file')
    end)
  end)

  insulate('when circular referrence', function()
    it('should throw error', function()
      _G.arg = { 'spec/fixtures/circular-referrence.lua' }
      assert.error_matches(function()
        dofile('onarum.lua')
      end, 'loop in require')
    end)
  end)

  it('should bundle file', function()
    _G.arg = { 'spec/fixtures/package.lua' }
    local act = require('onarum')
    local bdl = io.open('spec/fixtures/bundle.lua')
    local exp = bdl:read('*a')
    bdl:close()
    assert.same(exp, act)
  end)
end)
