name = ['A','B','C']
info = [1,2,3]
pro arraytostrct,struct
  struct = {name:name[0],info:info[0]}
  for i =1,2 do struct =[struct,{name: name[i],info:info[i]}]
end

  
