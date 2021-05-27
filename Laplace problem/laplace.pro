;an example of use:
;laplace,10000,1.95,0.5,0.5,'A',100,0,0,dphi05,phixA;
;above is an example to run case A with w=1.95, dx=dy=0.5, 10000 iterations
 
;to calculate the potential with ’for’ loop
pro laplace_iter, niter, w, phianode, anode, phiblende, blende, phirand, rand, phi, dphi, phix
  ; niter : times of iterations
  wm = 1.0-w
  dphi = dblarr(niter,/nozero);potential difference over two iterations
  phix = dblarr(niter,/nozero);potential at a fixed point [10,0]
  for i=0,niter-1 do begin
     d = 0.25*(shift(phi,1,0) + shift(phi,0,1) + shift(phi,-1,0) + shift(phi,0,-1))
     laplace_setbc, phianode, anode, phiblende, blende, phirand, rand, d
     d = 0.25*(shift(d,1,0) + shift(d,0,1) + shift(d,-1,0) + shift(d,0,-1))
     laplace_setbc, phianode, anode, phiblende, blende, phirand, rand, d
     dphi[i]=max(abs(phi-d))
     if (i mod 100 eq 0) then print, niter-i, dphi[i]
     phi = w*d + wm*phi
     phix[i] = phi[40,50]
  endfor
end

;to set values for fixed potentials like potential of anode = 100 
pro laplace_setbc, val1, mask1, val2, mask2, val3, mask3,phi
  phi[mask1] = val1
  phi[mask2] = val2
  phi[mask3] = val3
end

;to define different areas in the plane
pro laplace_setmask, sx, x, sy, y,casei, mask1, mask2, mask3
  nx = n_elements(x)
  ny = n_elements(y)
  xx = rebin(x, nx, ny)
  yy = transpose(rebin(y, ny, nx))
  mask1 = where(xx ge -2.0 and xx le 2.0 and  yy ge -2.0 and yy le 2.0)
  mask3 = where(xx eq max(x) or xx eq min(x) or yy eq max(y) or yy eq min(y))
  blend = where(xx ge  14.5 and xx le  15.5  and yy ge  -20.0 and yy le 20.0)
  node2 = where(xx ge  28.0 and xx le  32.0  and yy ge  -2.0 and yy le 2.0 ) 
  case casei of
     'A':mask2=mask3
     'B':mask2=blend
     'C':mask2=node2
  endcase
end

;to set colors
pro laplace_set_colors, red, yellow, blue, grey, white, green, orange
  red    = 255L
  yellow = 65535L
  blue   = 16711680L
  grey   = 11744050L
  white  = 16777215L
  green  = 65280L
  orange = 32895L
end




pro laplace,niter,w,dx,dy,casei,v1,v2,v3,dphi,phix
  laplace_set_colors, red, yellow, blue, grey, white, green,orange
  sx  = [-10.0, 40.0]
  sy  = [-25.0, 25.0]
  nx  = nint((sx[1]-sx[0])/dx)+1
  ny  = nint((sy[1]-sy[0])/dy)+1
  x   = sx[0]+findgen(nx)*dx
  y   = sy[0]+findgen(ny)*dy

  phi = dblarr(nx,ny) + randomu(iseed,nx,nx)*100.0
  phiB1  = v1
  phiB2  = v2
  phiB3  = v3

  laplace_setmask, sx, x, sy, y,casei,B1,B2,B3
  laplace_setbc, phiB1,B1,phiB2,B2,phiB3,B3, phi
  laplace_iter,niter, w,phiB1,B1,phiB2,B2,phiB3,B3,phi,dphi,phix

  levels=findgen(21)/20.0*2.0
  contour, phi, x, y, xstyle=5, ystyle=5, levels=levels, /iso, color=orange
           
  levels=findgen(21)/20.0*2.0-2
  contour, phi, x, y, xstyle=5, ystyle=5, levels=levels, /iso, $
           color=grey, /noerase
  
  levels=findgen(51)*2.0
  contour, phi, x, y, /xsty, /ysty, levels=levels, /noerase, /iso,color=yellow, $
           xtitle='x', ytitle='y'
  levels=findgen(51)*2.0-100
  contour, phi, x, y, /xsty, /ysty, levels=levels, /noerase, /iso,color=green, $
           xtitle='x', ytitle='y'
  
  polyfill, [-2, 2, 2, -2, -2], [-2, -2, 2, 2, -2], color=red
  case casei of
     'A' :break
     'B' :polyfill,[14.5,15.5,15.5,14.5,14.5],[-20,-20,20,20,20],color=blue
     'C' :polyfill,[28,32,32,28,28],[-2,-2,2,2,-2],color=blue
  endcase 

end

