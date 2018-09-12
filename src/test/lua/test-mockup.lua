local testSuite = TestSuite("mockup-testsuite")
testSuite:add(TestCase('abi', function()
  abi.register('test')
end))

testSuite:run()

