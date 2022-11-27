-- Highly performant list implementation that allows access as a stack or queue.
List = {}

-- Creates a new list
function List.new ()
  return {first = 0, last = -1, length=0}
end

-- Adds an element to the front of the list
function List.pushFront (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
  list.length+=1
end

-- Adds an element to the end of this list
function List.pushEnd (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
	list.length+=1
end

-- Removes an element from the front of the list
function List.popFront (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
	list.length-=1
  return value
end

-- Removes an element from the back of the list
function List.popEnd (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
	list.length-=1
  return value
end

-- Returns an element from the front of the list without removing it
function List.peekFront (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  return value
end

-- Returns an element from the back of the list without removing it
function List.peekEnd (list)
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

-- Executes the provided function on each element of the list
function List.forEach(list, func)  
  for i = list.first, list.last do
    func(list[i])
  end
end

-- Returns a new list populated by the same elements, transformed by the provided function
function List.map(list, func)
  local newList = List.new()
  List.forEach(list, function(element)
    List.pushFront(func(element))    
  end)
  return newList
end

-- Returns a new list populated by the elements for which the test function returns true
function List.filter(list, test)
  local newList = List.new()
  List.forEach(list, function(element)
    if (test(element)) then
      List.pushFront(element)
    end
  end)
  return newList
end