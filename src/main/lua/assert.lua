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
