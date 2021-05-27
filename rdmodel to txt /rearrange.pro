pro rearrange, str0,len,str1
  pos = strpos(str0,'a')
  cc = intarr(len)
  for i = 0,len-1 do cc[i] = strmid(str0[i],pos[i]+1)
  str1 = str0[sort(cc)]
end
