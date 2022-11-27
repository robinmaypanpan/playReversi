List = {}

-- Creates a new list
function List.new ()
  return {first = 0, last = -1, length=0}
end

-- Adds an element to the front of the list
function List.pushleft (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
  list.length+=1
end

-- Adds an element to the end of this list
function List.pushright (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
	list.length+=1
end

-- Removes an element from the front of the list
function List.popleft (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
	list.length-=1
  return value
end

-- Removes an element from the back of the list
function List.popright (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
	list.length-=1
  return value
end

-- Returns an element from the front of the list without removing it
function List.peekleft (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  return value
end

-- Returns an element from the back of the list without removing it
function List.peekright (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  return value
end

-- Returns true if the provided test evaluates to true for any of the provided elements
function List.check(list, test)
  for i = list.first, list.last do
    if (test(list[i])) then
      return true
    end
  end
  return false
end

-- Returns the index of the element in the list for which the test returns true, -1 if none
function List.findIndex(list, test)
  for i = list.first, list.last do
    if (test(list[i])) then
      return i
    end
  end
  return -1
end

-- Returns the the element in the list for which the test returns true, nil if none
function List.find(list, test)
  for i = list.first, list.last do
    if (test(list[i])) then
      return list[i]
    end
  end
  return nil
end