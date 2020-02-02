--------------------------------------------------------------
--
-- Test framework for lua contract
--
require "ship.test.Athena"

TestCase = { }
TestCaseMetatable = { __index = TestCase }
setmetatable(TestCase, {
  __call = function(cls, ...)
    return cls.new(...)
  end
})

function TestCase.new(name, runnable) 
  return setmetatable({
    name = name,
    runnable = runnable,
    error = nil
  }, TestCaseMetatable)
end

function TestCase:expected(error)
  self.error = error
  return self
end

function TestCase:run()
  TestReporter.startTest(self.name)
  local result, err = pcall(self.runnable)
  if self.error then
    if err then
      local handledResult = self.error(err)
      if not handledResult then
        TestReporter.recordError(self.name, 'User unexpected error: ' .. err)
      end
    else
      TestReporter.recordError(self.name, 'No error')
    end
  elseif err then
    TestReporter.recordError(self.name, 'Unexpected error: ' .. err)
  end
  TestReporter.endTest(self.name)
end

local TestSuite = { }
TestSuite.__index = TestSuite
setmetatable(TestSuite, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})
function TestSuite.new(name)
  local self = setmetatable({}, TestSuite)
  self.name = name
  self.testCases = {}
  return self
end

function TestSuite:run()
  local n = self.name
  TestReporter.startSuite(n)
  for name, testCase in pairs(self.testCases) do 
    testCase:run()
  end
  TestReporter.endSuite(self.name)
end
function TestSuite:add(testCase)
  local name = testCase.name
  self.testCases[name] = testCase
end


--------------------------------------------------------------
--
-- Mock-up for aergo server environment
--
require "ship.test.Athena"

_G.print = nil
_G.dofile = nil
_G.loadstring = nil
_G.loadfile = nil
_G.dofile = nil
_G.module = nil

abi = {
  register = function (funcname, ...)
  end
}

json = {
  encode = function(obj)
  end,
  decode = function(str)
  end
}

contract = {
  send = function (address, amount)
  end,
  delegatecall = function(address, funcname, ...) -- ... is function arguments
  end,
  pcall = function(func, ...) -- ... is function arguments
  end
}

db = {}

function db.exec(sql_stmt)
end

db._rs_meta = {}
db._rs_meta.__index = db._rs_meta

function db._rs_meta:next()
end

function db._rs_meta:get()
end

function db.query(sql_stmt)
  return setmetatable({}, db._rs_meta)
end

db._pstmt_meta = {}
db._pstmt_meta.__index = db._pstmt_meta

function db._pstmt_meta:exec(...) -- ... is bind parameters
end

function db._pstmt_meta:query(...) -- ... is bind parameters
  return setmetatable({}, db._rs_meta)
end

function db.prepare(sql_stmt)
  return setmetatable({}, db._pstmt_meta)
end

state = {}

function state.var(tbl)
  for key, value in pairs(tbl) do
    rawset(value, "_id_", key)
    _G[key] = value
  end
end

state._value_meta = {}
state._value_meta.__index = state._value_meta

function state._value_meta:get()
  return self._val
end

function state._value_meta:set(val)
  self._val = val
end

function state.value()
  return setmetatable({ _type_= "value" }, state._value_meta)
end

function state._map_delete(self, key)
  self[key] = nil
end

function state._map_check_key(k)
  if type(k) ~= "number" and type(k) ~= "string" then
    error("key error: number or string expected, got " .. type(k))
  end
end

state._map_meta = {
  __index = function(t, k)
    state._map_check_key(k)
    return rawget(t, k)
  end,
  __newindex = function(t, k, v)
    state._map_check_key(k)
    rawset(t, k, v)
  end
}

function state.map()
  return { _type_ = "map", delete = state._map_delete }
end

function state.array_length(self)
  return rawget(self, "_len_")
end

function state.array_iter(a, i)
  local n = i + 1
  if n <= rawget(a, "_len_") then
    return n, a[n]
  end
  return nil, nil
end

function state.array_ipairs(self)
  return state.array_iter, self, 0
end

function state._array_check_key(k, l)
  if type(k) ~= "number" then
    error("key error: number expected, got " .. type(k))
  end
  if k % 1 ~= 0 then
    error("key error: integer expected, got " .. tostring(k))
  end
  if k < 0 or k > l then
    error("key error: index out of range " .. tostring(k))
  end
end

state._array_meta = {
  __index = function(t, k)
    state._array_check_key(k, rawget(t, "_len_"))
    return rawget(t, k)
  end,
  __newindex = function(t, k, v)
    state._array_check_key(k, rawget(t, "_len_"))
    rawset(t, k, v)
  end
}

function state.array(len)
  return setmetatable({ _type_ = "array", _len_ = len, length = state.array_length, ipairs = state.array_ipairs },
                      state._array_meta)
end
--------------------------------------------------------------
--
-- Utility for assertion
--
function assertTrue(exp, message)
  if exp then
    return
  end

  if message then
    error(message, 0)
  else
    error("expression must be ture", 0)
  end
end

function assertFalse(exp, message)
  if not exp then
    return
  end

  if message then
    error(message, 0)
  else
    error("expression must be ture", 0)
  end
end

function assertNotEquals(a, b, message)
  if actual ~= expected then
    return 
  end

  if message then
    error(message, 0)
  else
    error(tostring(actual) .. " is equal to " .. tostring(expected) .. ". Two value should not be equal.", 0)
  end

end

function assertEquals(expected, actual, message)
  if actual == expected then
    return 
  end

  if message then
    error(message, 0)
  else
    error(tostring(actual) .. " is not equal to " .. tostring(expected) .. ". Expected: " .. tostring(expected) .. ", Actual: " .. tostring(actual), 0)
  end
end

function assertNull(actual, message)
  if nil == actual then
    return 
  end

  if message then
    error(message, 0)
  else
    error(tostring(actual) .. " must be null", 0)
  end
end

function assertNotNull(actual, message)
  if nil ~= actual then
    return 
  end

  if message then
    error(message, 0)
  else
    error("value must not be null", 0)
  end
end
