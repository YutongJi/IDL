pro rdmodel, directoryname, filename, struct
  
;-----------------------------------------------------------------------------------------------------------------------------------
; NAME:
;  rdmodel
;
; PURPOSE:
;  Read data to IDL structure & txt file
;
; INPUT:
;  Directory name where the files are kept & structure and txt file
;  name
;
; OUTPUT:
;  IDL structure
;  txt file
;
; EXAMPLE:
;  .run rdmodel.pro
;  rdmodel, '/d/hgl/snaps', 'file.txt',structure
;  help,/str,structure
;  
;--------------------------------------------------------------------------------------------------------------------------------------
  
  ;----------------------------------------------- to define structure parameters----------------------------------------------------
  models = file_search(directoryname,'d3*',count=nmodels,/test_directory); get the list of models in the directory
  Modelnames = strarr(nmodels)
  nfullfiles = intarr(nmodels,2)
  directoryfull = strarr(nmodels,2)
  directorylhd = strarr(nmodels)
  FileLHDa05a10a15a20 = strarr(nmodels,4)
  FileReadme = strarr(nmodels,2)
  FileMSMean = strarr(nmodels)
  FilePar = strarr(nmodels)
  OptaTable = strarr(nmodels)
  OptaBins = make_array(nmodels, /INTEGER, VALUE = 999) ;for indgen or float form infomation, 999  means that infomation is not given
  FileEOS = strarr(nmodels)
  FileGAS = strarr(nmodels)
  Nxyz = make_array(nmodels,3,/INTEGER, VALUE = 999)
  Lxyz = make_array(nmodels,3,/FLOAT, VALUE = 999)
  TeffNominal = make_array(nmodels, /float, value = 999)
  TeffSelection = make_array(nmodels,2, /float, value = 999)
  Grav = make_array(nmodels,/float, value = 999)
  M_H  = make_array(nmodels, /float, value = 999)
  alpha_Fe = make_array(nmodels,/float, value = 999)
  CNO_Fe = make_array(nmodels,3, /float , value =999)

 
  ;------------------------------------------- to get gas file name from eos file's------------------------------------------
  ; 'eosgas' routine is to find gas file according to eos file
  eosgas,'correspondence.txt',eos_gas_map
  openw,unit,filename,/get_lun
  printf,unit, 'xxxTable'
  printf,unit, ''
  printf,unit, FORMAT ='("ModelID: Name of the model",30X)'
  printf,unit, FORMAT ='("nFUllfiles: numbers of full files in bigsel(first)/smallsel(second)",27X)'
  printf,unit, FORMAT ='("Directoryfull: direcoties which contain full files",24X)'
  printf,unit, FORMAT ='("DirectoryLHD: directory which contains lhdmodels",25X)'
  printf,unit, FORMAT ='("FileLHDa05a10a15a20: lhd files",18X)'
  printf,unit, FORMAT ='("FileReadme: readme file in the model",27X)'
  printf,unit, FORMAT ='("FileMSMean: MSmean file in the model",27X)'
  printf,unit, FORMAT ='("FilePar: location of the par file",30X)'
  printf,unit, FORMAT ='("OptaTable: opta file of the model",28X)'
  printf,unit, FORMAT ='("Optabins: nbands in opta file",29X)'
  printf,unit, FORMAT ='("FileEOS: corresponding EOS file",30X)'
  printf,unit, FORMAT ='("FileGAS: corresponding GAS file",30X)'
  printf,unit, FORMAT ='("Nxyz: numbers of grinds in x/y/z directions",33X)'
  printf,unit, FORMAT ='("Lxyz: physical size of the model",33X)'
  printf,unit, FORMAT ='("TeffNominal: effective temperature inferred from model name",26X)'
  printf,unit, FORMAT ='("TeffSelection: effective temperature in readme files",24X)'
  printf,unit, FORMAT ='("Grav: gravity",33X)'
  printf,unit, FORMAT ='("M_H: metalicity",34X)'
  printf,unit, FORMAT ='("alpha_Fe: alpha enhancement",29X)'
  printf,unit, FORMAT ='("CN0_Fe: CN0 enhancement",31X)'
  printf,unit, ''

  ;----------------------------------------------- run through all the model directories-----------------------------------------------------
  for i = 0, nmodels-1 do begin
     ;------------------------ to get model names(ModelID) and store it in modelnames array-----------------------
     ;modelnames[i] = strmid(models[i],13) 
     modelnames[i] = file_basename(models[i])
     
     ;------------------------ to get filemsmean and store it in the filemsmean list--------------------------
     tmpFileMSMean = file_search(models[i],'*.avg_z_tau.idlsave') ;tmpFileMSMean is a string/array(depends on the search results) used to store the full names of search results(including full file path)
     if ~tmpFileMSMean[0] eq '' then begin
        exname, tmpfilemsmean[0], modelnames[i], filemsmean0 ;'exname' is a routine aming to shorten the names, i.e delete up directories
        filemsmean[i]= filemsmean0
     endif

     ;------------------------ to get lhd derectory and store it in the directorylhd array--------------------
     tmpdirectorylhd = file_search(models[i],'lhdmodels',/test_directory)
     if ~tmpdirectorylhd[0] eq '' then  begin ;make sure tmpdirectorylhd is not empty string/array(if the first element is not '' then it means there is at least one lhdmodels in this model)
        exname, tmpdirectorylhd[0],modelnames[i],directorylhd0
        directorylhd[i] = directorylhd0 +  '/'
     endif

     ;------------------------ to get par file and store it in the filepar array-------------------------------
     tmpFilePar = file_search(models[i],'*.par')
     if ~tmpFilePar[0] eq '' then begin
        exname, tmpfilepar[0], modelnames[i], filepar0
        filepar[i] = filepar0
     endif

     ;------------------------ to get lhd files, rearrange and store them in the 2-D filelhda05a10a15a20 array-------------------
     tmpFileLHDa05a10a15a20 = file_search(models[i],'*a*.l50')    
     dim = size(tmpFileLHDa05a10a15a20,/dimensions)
     len = size(tmpFileLHDa05a10a15a20,/n_elements)
     if dim eq 0 or len gt 4 then  Filelhda05a10a15a20[i] = '' $ ;if the model contains more than 4 files make it empty, in /d/hgl/snaps only Model D3t38g40mm10n3 has more than 4 files and add the info manually later
     else begin
        ;rearrange the files according to a05, a10, a15, a20
        disFilelhda05a10a15a20 = strarr(len)
        for j = 0,len-1 do begin
           if ~tmpFileLHDa05a10a15a20[j] eq '' then $
              disFilelhda05a10a15a200 = file_basename(tmpFileLHDa05a10a15a20[j])
              disFilelhda05a10a15a20[j] = disFilelhda05a10a15a200              
           endfor
        tmpdisFilelhda05a10a15a20 = strarr(4)
        rearrange, disFilelhda05a10a15a20,len,tmpdisFilelhda05a10a15a20

        len2 = size(tmpdisFilelhda05a10a15a20,/n_elements)
        for j = 0, len2-1 do Filelhda05a10a15a20[i, j] = tmpdisFilelhda05a10a15a20[j]
     endelse



    
     ;------------------------ to get Lxyz and Nxyz info from full files---------------------------------------------
     resultfull = file_search(models[i],'*.full')
     if ~size(resultfull,/dimensions) eq 0 then begin
         if modelnames[i] eq 'd3t48g32mm00n01' then tmpfull = resultfull[2] else  tmpfull = resultfull[0] ;model 'd3t48g32mm00n01' has a problem with its full files as its first two full files can not be read
         boxsizenew,tmpfull, h,v,ny,nz,silent = silent ;boxsizenew is a routine to get size info from full files
         Lxyz[i,*] = [v,v,h]
         Nxyz[i,*] = [ny,ny,nz]
      endif
     
     ;------------------------ to get model bigsels numbers  and information in the bigsels---------------- 
     tmpbsel = file_search(models[i],'bigsel*' or 'sel_*ss',/test_directory)
     ;lenbsel = size(tmpbsel,/n_elements)

     if ~tmpbsel[0] eq '' then begin
        result0 = file_search(tmpbsel[0],'*.full',count = bb)
        nfullfiles[i,0] = bb ;to get the number of full files in bigsel and store it in the 2-d array nfullfiles as [i,0] element
        if ~size(result0,/dimensions) eq 0 then begin
           exname,tmpbsel,modelnames[i],directoryfull0
           directoryfull[i,0] = directoryfull0 + '/'
        endif            
        tmpreadme0 = file_search(tmpbsel[0],'readme*.txt')  ;search for readme file in bigsel and store the results in the tmpreadme0      

        if ~size(tmpreadme0,/dimensions) eq 0 then begin
           FileReadMe[i,0] = directoryfull0 + '/'+ file_basename(tmpreadme0[0])
           rdme,tmpreadme0[0],teffselection0           
           Teffselection[i,0] =  Teffselection0
        endif
     endif
     
    ;------------------------ to get model smallsels numbers and information in the smallsels----------------------------------
     tmpssel = file_search(models[i],'smallsel*',/test_directory)
     if ~tmpssel eq '' then begin
        result1 = file_search(tmpssel,'*.full',count = aa )
        nfullfiles[i,1] = aa;get the number of full files in smallsel and store it in the 2-d array nfullfiles as [i,1] element
        if ~result1[0] eq '' then begin
           exname, tmpssel, modelnames[i],directoryfull1
           directoryfull[i,1] = strmid(directoryfull1,1) + '/'
        endif
        tmpreadme1 =  file_search(tmpssel,'readme*') ;search for readme file in small sel and store the results in the tmpreadme1
        if ~size(tmpreadme1,/dimensions) eq 0 then begin
           FileReadme[i,1] = directoryfull1 + '/'+ file_basename(tmpreadme1[0])           
           rdme,tmpreadme1[0],teffselection1
           Teffselection[i,1] = teffselection1
        endif
     endif

     ;------------------------ to extract info from par files like optatable, effective temperature and etc.---------------------------
     if ~tmpFilePar[0] eq '' then begin
         ;print, tmpFilePar[0]
         dpar = uio_struct_rd(tmpFilePar[0])
         OptaTable[i] = dpar.opafile
         TeffNominal[i] = dpar.teff
         Grav[i] = dpar.grav
         ;get opta file and extract info from it
         opafilename = file_search('~hgl/opta', dpar.opafile)
         ;use dfopta routine to get optabins and eos file
         common opta_common, nt, np, nband, topta, popta, xopta 
         Dfopta,opafilename 
         optabins[i] = nband
         FileEos[i] = dpar.eosfile
         ; get gas file from eos_gas_map according to the eos file 
         if ~FileEos[i] eq '' then begin
            Filegas[i] = eos_gas_map[where(eos_gas_map eq fileeos[i]),1]
                                ;get metalicity and alpha enhancement info
                                ;from name of the eos file name
            str1 = fileeos[i]
            str2 = ''
            str3 = ''
            if strmatch(str1,'*6_m*') then str2 = strmid(str1, strpos(str1,'_m')+2) & str3 = strmid(str1, strpos(str1,'_a')+2)
            if strmatch(str1,'*_mm*') then str3 = strmid(str1, strpos(str1,'_mm')+3)
                                ;now str2 & 3 are number begind m and a respectively
            if ~str2 eq '' then M_H[i] = ('-' + strmid(str2,0,2)+0.0)/10
            if ~str3 eq '' then alpha_Fe[i] = (strmid(str3,0,2)+0.0)/10
         endif
     endif

     
     ;------------------------ to store info from arraies to an anonymous structure----------------------------------------
     if i eq 0 then begin
        struct = {Modelname:modelnames[i],$
                  FileMsMean: filemsmean[i],$
                  FilePar: filepar[i],$
                  DirectoryLHD:directorylhd[i],$
                  Filelhda05a10a15a20:Filelhda05a10a15a20[i,*],$
                  nFullFiles: nfullfiles[i,*],$
                  DirectoryFull:directoryfull[i,*],$
                  Lxyz: Lxyz[i,*],$
                  Nxyz: Nxyz[i,*],$
                  FileReadme: filereadme[i,*],$
                  Teffselection:teffselection[i,*],$
                  OptaTable: Optatable[i],$
                  Grav:Grav[i],$
                  TeffNominal:TeffNominal[i],$
                  Optabins: optabins[i],$
                  FileEos: FileEos[i],$
                  FileGas: FileGas[i],$
                  M_H: M_H[i],$
                  alpha_Fe: alpha_Fe[i]$                 
                 }
     endif else begin
        struct = [struct, {Modelname:modelnames[i],$
                           FileMsMean: filemsmean[i],$
                           FilePar: filepar[i],$
                           DirectoryLHD:directorylhd[i],$
                           Filelhda05a10a15a20:Filelhda05a10a15a20[i,*],$
                           nFullFiles: nfullfiles[i,*],$
                           DirectoryFull:directoryfull[i,*],$
                           Lxyz: Lxyz[i,*],$
                           Nxyz: Nxyz[i,*],$
                           FileReadme: filereadme[i,*],$
                           Teffselection:teffselection[i,*],$
                           OptaTable: Optatable[i],$
                           Grav:Grav[i],$
                           TeffNominal:TeffNominal[i],$
                           Optabins: optabins[i],$
                           FileEos: FileEos[i],$
                           FileGas: FileGas[i],$
                           M_H: M_H[i],$
                           alpha_Fe: alpha_Fe[i]$ 
        }]
     endelse
     
     ;------------------------------- to store info from the arraies to a txt file -------------------------------------
     printf,unit,Modelnames[i],FORMAT = "('ModelID:',30X,1H',A0,1H')"
     printf,unit,nfullfiles[i,0],nfullfiles[i,1],FORMAT = "('nFullFiles:',27X,I0,2X,I0)"
     printf,unit,directoryfull[i,0],directoryfull[i,1],FORMAT =  "('DirectoryFull:',24X,1H',A0,1H',3X,1H',A0,1H')"          
     printf,unit,directorylhd[i],FORMAT =  "('DirectoryLHD:',25X,1H',A0,1H')"
     printf,unit,FileLHDa05a10a15a20[i,0],FORMAT = "('FileLHDa05a10a15a20:',18X,1H',A0,1H')"
     if ~FileLHDa05a10a15a20[i,1] eq '' then printf,unit,FileLHDa05a10a15a20[i,1],FORMAT = "(38X,1H',A0,1H')"
     if ~FileLHDa05a10a15a20[i,2] eq '' then printf,unit,FileLHDa05a10a15a20[i,2],FORMAT = "(38X,1H',A0,1H')"
     if ~FileLHDa05a10a15a20[i,3] eq '' then printf,unit,FileLHDa05a10a15a20[i,3],FORMAT = "(38X,1H',A0,1H')"
     printf,unit,FileReadme[i,0],FileReadme[i,1],FORMAT =  "('FileReadme:',27X,1H',A0,1H',2X,1H',A0,1H')"
     printf,unit,FileMSMean[i],FORMAT = "('FileMSMean:',27X,1H',A0,1H')" 
     printf,unit,FilePar[i],FORMAT =  "('FilePar:',30X,1H',A0,1H')"
     printf,unit,OptaTable[i],FORMAT =  "('OptaTable:',28X,1H',A0,1H')"
     printf,unit,OptaBins[i],FORMAT =  "('OptaBins:',29X,I0)"
     printf,unit,FileEOS[i],FORMAT =  "('FileEOS:',30X,1H',A0,1H')"
     printf,unit,FileGAS[i],FORMAT =  "('FileGAS:',30X,1H',A0,1H')"
     printf,unit,Nxyz[i,0],Nxyz[i,1],Nxyz[i,2],FORMAT =  "('Nxyz:',33X,I0,2X,I0,2X,I0)"
     printf,unit,Lxyz[i,0],Lxyz[i,1],Lxyz[i,2],FORMAT =  "('Lxyz:',33X,g0,2X,g0,2X,g0)"
     ; ------------------------to unify 999.0, 999.00 with 999-----------------------------------------------------------
                                ; following way for parameters with
                                ; more than one values is a bit
                                ; redundant and need to be improved/simplified
     if TeffNominal[i] eq 999 then printf,unit,TeffNominal[i],FORMAT =  "('TeffNominal:',26X,I0)" else printf,unit,TeffNominal[i],FORMAT =  "('TeffNominal:',26X,f0.2)"
     if  TeffSelection[i,0] eq 999 and   TeffSelection[i,1] eq 999 then printf,unit,TeffSelection[i,0],TeffSelection[i,1],FORMAT =  "('TeffSelection:',24X,I0,2X,I0)"     
     if  TeffSelection[i,0] eq 999 and  ~TeffSelection[i,1] eq 999 then printf,unit,TeffSelection[i,0],TeffSelection[i,1],FORMAT =  "('TeffSelection:',24X,I0,2X,f0.2)"
     if ~TeffSelection[i,0] eq 999 and   TeffSelection[i,1] eq 999 then printf,unit,TeffSelection[i,0],TeffSelection[i,1],FORMAT =  "('TeffSelection:',24X,f0.2,2X,I0)"
     if ~TeffSelection[i,0] eq 999 and  ~TeffSelection[i,1] eq 999 then printf,unit,TeffSelection[i,0],TeffSelection[i,1],FORMAT =  "('TeffSelection:',24X,f0.2,2X,f0.2)"
     if Grav[i] eq 999 then printf,unit,Grav[i],FORMAT =  "('Grav:',33X,I0)" else  printf,unit,Grav[i],FORMAT =  "('Grav:',33X,f0.1)"
     if M_H[i]  eq 999 then printf,unit,M_H[i],FORMAT =  "('M_H:',34X,I0)"   else  printf,unit,M_H[i],FORMAT =  "('M_H:',34X,f0.1)"
     if alpha_Fe[i] eq 999 then printf,unit,alpha_Fe[i],FORMAT =  "('alpha_Fe:',29X,I0)" else printf,unit,alpha_Fe[i],FORMAT =  "('alpha_Fe:',29X,f0.1)"
     ;printf,unit,CNO_Fe[i,0],CNO_Fe[i,1],CNO_Fe[i,2],FORMAT =  "('CNO_Fe:',31X,f0.1,2X,f0.1,2X,f0.1)"
     printf,unit,CNO_Fe[i,0],CNO_Fe[i,1],CNO_Fe[i,2],FORMAT =  "('CNO_Fe:',31X,I0,2X,I0,2X,I0)" ;in this case just assume all CNO info not given 
     printf,unit,''
  endfor
  free_lun,unit  
end


    




