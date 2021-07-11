--https://stackoverflow.com/a/30815687
function table.clear(tbl)
  if type(tbl) == 'table' then
    local count = #tbl
    for i = 0, count do
      tbl[i] = nil
    end
  end
end
