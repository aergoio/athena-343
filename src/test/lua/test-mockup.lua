local testSuite = TestSuite("mockup-testsuite")

testSuite:add(TestCase('abi', function()
  abi.register('test')
end))

testSuite:add(TestCase('system.setItem/getItem', function()
  system.setItem("id1", "kslee")
  assertEquals("kslee", system.getItem("id1"))
end))

testSuite:add(TestCase('state variables', function()
  state.var {
    Counts = state.map(),
    Arr = state.array(3),
    Name = state.value()
  }

  -- state.map
  Counts["name"] = "kslee"
  Counts["age"] = 38
  Counts[1] = "first"
  assertEquals("kslee", Counts["name"])
  assertEquals(38, Counts["age"])
  assertEquals("first", Counts[1])
  Counts:delete(1)
  assertEquals(nil, Counts[1])

  -- state.value
  Name:set("kslee")
  assertEquals("kslee", Name:get())

  -- state.array
  Arr[1] = "first"
  Arr[2] = "second"
  Arr[3] = "third"
  assertEquals("second", Arr[2])

  local expectedArr = { "first", "second", "third" }
  for i, v in Arr:ipairs() do
    assertEquals(expectedArr[i], v)
  end

  for i = 1, Arr:length() do
    assertEquals(expectedArr[i], Arr[i])
  end
end))

testSuite:add(TestCase("db", function()
  db.exec("dml/ddl")
  local rs = db.query("query")
  rs:next()
  rs:get()
  local pstmt = db.prepare("query")
  pstmt:exec("arg1", "arg2")
  local rs1 = pstmt:query("arg1", "arg2")
  rs1:next()
  rs1:get()
end))

testSuite:add(TestCase("json", function()
  json.encode({})
  json.decode("...")
end))

testSuite:add(TestCase("contract", function()
  contract.send("0x000", 10)
  contract.delegatecall("0x000", inc, "arg1", "arg2")
  contract.pcall(dec, "arg1", "arg2")
end))

testSuite:run()

