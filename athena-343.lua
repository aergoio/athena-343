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
--------------------------------------------------------------
--
-- Mock-up for aergo server environment
--
function getItem(key)
  return value
end

function setItem(key, value)
end

function getSender()
  return address
end

function getCreator()
  return address
end
function getBlockhash()
  return hash
end
function getBlockheight()
  return height
end
function Timestamp()
end
function getContractID()
  return id
end
function getTxhash()
  return hash
end
function getNode()
  return id
end

abi = {}
function abi.register(funcname, ...)
end
--------------------------------------------------------------
--
-- Test framework for lua contract
--
require "hera.test.Athena"

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
    result = self.error(err)
    if result then
      error = nil
    else
      error = 'Unexpected error'
    end
  end
  if err then
    TestReporter.recordError(self.name, err == nil)
  end
  TestReporter.endTest(self.name, result)
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


