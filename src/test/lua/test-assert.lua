local testSuite = TestSuite("assert-testsuite")
testSuite:add(TestCase('assertEquals', function()
  assertEquals(true, true)
  assertEquals(false, false)
end))

testSuite:add(TestCase('assertEquals with custom message', function()
  assertEquals(false, false, 'This is custom message')
  assertEquals(false, false, 'This is custom message2')
end))

testSuite:add(TestCase('expected', function()
  assertTrue(false, 'error')
end):expected(function(error)
  return string.match(error, 'error')
end))

testSuite:run()
