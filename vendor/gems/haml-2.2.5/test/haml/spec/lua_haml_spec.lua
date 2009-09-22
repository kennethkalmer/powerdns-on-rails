require 'luarocks.require'
require 'json'
require 'telescope'
require 'haml'

local function get_tests(filename)
  local self = debug.getinfo(1).short_src
  if self:match("/") then return "./" .. self:gsub("[^/]*%.lua$", "/" .. filename)
  elseif self:match("\\") then return self:gsub("[^\\]*%.lua$", "\\" .. filename)
  else return filename
  end
end

local fh = assert(io.open(get_tests("tests.json")))
local input = fh:read '*a'
fh:close()

local contexts = json.decode(input)

local locals = {
  var   = "value",
  first = "a",
  last  = "z"
}

describe("The LuaHaml Renderer", function()
  for context, expectations in pairs(contexts) do
    describe("When handling " .. context, function()
      for input, expectation in pairs(expectations) do
        it(string.format("should render '%s' as '%s'", string.gsub(input, "\n", "\\n"),
            string.gsub(expectation, "\n", "\\n")), function()
            assert_equal(haml.render(input, {}, locals), expectation)
        end)
      end
    end)
  end
end)
