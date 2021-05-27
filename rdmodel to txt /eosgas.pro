pro eosgas, filename, eos_gas
  eos_gas = strarr(30,2)
  openr,unit, filename,/get_lun
  line =''
  i = -1L
  While ~eof(unit) do begin
      readf, unit, line
      i = i+1
      ;print,line
      tmpeosgas = strsplit(line,/extract)
      ;print,tmpeosgas[1]
      eos_gas[i,0] = tmpeosgas[0]
      eos_gas[i,1] = tmpeosgas[1]
  endwhile
  free_lun,unit
  ;eos_gas = eos_gas[0:i]
end
