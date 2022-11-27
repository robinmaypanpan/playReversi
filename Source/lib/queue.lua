List = {}

function List.new ()
  return {first = 0, last = -1, length=0}
end

function List.pushleft (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
  list.length+=1
end

function List.pushright (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
	list.length+=1
end

function List.popleft (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
	list.length-=1
  return value
end

function List.popright (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
	list.length-=1
  return value
end

function List.find(list, test)
  for i = list.first, list.last do
    if (test(list[i])) then
      return true
    end
  end
  return false
end