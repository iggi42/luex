local _dump = function(t, l)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys)
  for i = 1, #keys do
    local k = keys[i]
    local v = t[k]
    if type(v) == 'table' then
      dump(v, l + 1)
    else
      print(string.rep(' ', l) .. string.format("%3i", k) .. ': ' .. v)
    end
  end
end

function dump(t)
  _dump(t, 0)
end

if type(arg) == 'table' then
  table.sort(arg)
  dump(arg)
else
  print("'arg' not found")
end
