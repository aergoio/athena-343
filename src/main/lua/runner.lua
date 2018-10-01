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
        TestReporter.recordError(self.name, 'User unexpected error')
      end
    else
      TestReporter.recordError(self.name, 'No error')
    end
  elseif err then
    TestReporter.recordError(self.name, 'Unexpected error')
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


