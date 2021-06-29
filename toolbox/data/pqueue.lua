---
-- @module toolbox.data.pqueue

pqueue = {}

local supportArgs = {keyFunc=true}
function pqueue.new(args)
  t = {}
  if args then
    for k,v in pairs(args) do
      if supportArgs[k] then
        t[k] = v
      end
    end
  end
  return t
end

function pqueue.setKey(t, node)
  if not t.keySet then
    t.keySet = {}
  end
  local key = t.keyFunc(node.data)
  t.keySet[key] = node
end

function pqueue.delKey(t, node)
  local key = t.keyFunc(node.data)
  t.keySet[key] = nil
end

function pqueue.contains(t, data)
  local key = t.keyFunc(data)
  return not t.keySet[key] ~= nil
end

function pqueue.get(t, data)
  local key = t.keyFunc(data)
  return t.keySet[key]
end

function pqueue.height(t)
  return math.ceil(math.log(#t + 1,2))
end

function pqueue.parent(i)
  return math.max(1, math.floor((i-1)/2) + 1)
end

function pqueue.leftChild(i)
  return i*2
end

function pqueue.rightChild(i)
  return i*2+1
end

function pqueue.node(priority, data)
  return {
    priority = priority,
    data = data
  }
end

function pqueue.less(t, i1, i2)
  return t[i1].priority < t[i2].priority
end

function pqueue.more(t, i1, i2)
  return t[i1].priority > t[i2].priority
end

function pqueue.swim(t, i)
  while pqueue.less(t, i, pqueue.parent(i)) do
    pqueue.swap(t, i, pqueue.parent(i))
    i = pqueue.parent(i)
  end
end

function pqueue.sink(t, i)
  while i < #t do
    local left = pqueue.leftChild(i)
    local right = pqueue.rightChild(i)
    if left > #t then
      break
    end
    if right > #t then
      if pqueue.less(t, left, i) then
        pqueue.swap(t, left, i)
      end
      break
    end
    if pqueue.less(t, right, left) then
      pqueue.swap(t, i, right)
      i = right
    else
      pqueue.swap(t, i, left)
      i = left
    end
  end
end

function pqueue.insert(t, priority, data)
  local i = #t + 1
  local node = pqueue.node(priority, data)
  t[i] = node
  if t.keyFunc then
    local key = t.keyFunc(node.data)
    pqueue.setKey(t, t[i])
  end
  pqueue.swim(t, i)
end

function pqueue.swap(t, i1, i2)
    tmp = t[i2]
    t[i2] = t[i1]
    t[i1] = tmp
end

function pqueue.poll(t)
  local top = t[1]
  pqueue.swap(t, 1, #t)
  table.remove(t)
  pqueue.sink(t, 1)
  pqueue.delKey(t, top)
  return top
end

function pqueue.find(t, data)
  
end

function pqueue.remove(t, data)

end

function pqueue.printList(t)
  local tmp = {} for i,v in ipairs(t) do table.insert(tmp, v.data) end
  print(table.unpack(tmp))
end

function pqueue.print(t)
  local height = pqueue.height(t)
  for i=1,height do
    local tmp = {}
    --table.insert(tmp, i)
    for j=0,math.pow(2,i-1) - 1 do
      local idx = math.pow(2,i-1) + j
      table.insert(tmp, t[idx].data)
      if idx >= #t then
        break
      end
    end
    print(table.unpack(tmp))
  end
end

return pqueue
