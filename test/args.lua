local function _dump(t, l)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys)
  for i = 1, #keys do
    local k = keys[i]
    local v = t[k]
    local indentation = string.rep(' ', l);
    print(indentation .. tostring(k) .. ': ' .. tostring(v))
    if type(v) == 'table' then
      _dump(v, l + 1)
    end
  end
end

local function dump(t)
  _dump(t, 0)
end

dump({
  a = 123;
  b = {
    c = 23;
    d = 89;
    e = {
      f = "jklj";
    };
  };
})

if type(arg) == 'table' then
  table.sort(arg)
  dump(arg)
else
  print("'arg' not found")
end
