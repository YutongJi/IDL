pro boxsizenew, filename, hsize, vsize,ny,nz, silent=silent
  f = uio_dataset_rd(filename)
  s = size(f.z.rho)
  ny = s(2)
  nz = s(3)
  hsize= ny*(f.z.xc2(1)-f.z.xc2(0)) 
  vsize= (f.z.xb3(nz)-f.z.xb3(0)) 
  ;if (not keyword_set(silent)) then begin
     ;print, 'boxsize: hsize=', hsize 
     ;print, 'boxsize: vsize=', vsize
    ; endif
end
