FUNCTION OnClick(pCmd, pKey)
pCmd   = pCmd + '.'
pKey   = IIF(PCOUNT() = 1, 0, pKey)
nTop   = &pCmd.Top
nLeft  = &pCmd.Left
nDown  = &pCmd.Top + &pCmd.Height
nRight = &pCmd.Left + &pCmd.Width
RETURN (MDOWN() AND MROW(WINDOW(), 3) >= nTop AND MROW(WINDOW(), 3) <= nDown AND MCOL(WINDOW(), 3) >= nLeft AND MCOL(WINDOW(), 3) <= nRight) OR LASTKEY() = pKey &&OR MROW() < 0
ENDFUNC


FUNCTION OnFunction
RETURN LASTKEY() = 15 OR LASTKEY() = 16 OR LASTKEY() = 18 OR LASTKEY() = 147 OR LASTKEY() = -100 OR LASTKEY() = 19 OR LASTKEY() = 14 &&OR LASTKEY() = 50
ENDFUNC

*!*	&& koneksi, strsql, cursor
*!*	FUNCTION f_konek(p_para1,p_para2,p_para3)
*!*	nilai=1
*!*	fl_kon = SQLSTRINGCONNECT("&p_para1")
*!*	IF fl_kon>0 && berhasil
*!*		IF PCOUNT()<=2 && without cursor
*!*			   SQLEXEC(fl_kon,"&p_para2")
*!*			   SQLDISCONNECT(fl_kon)
*!*			   nilai=0
*!*		ELSE
*!*			   SQLEXEC(fl_kon,"&p_para2","&p_para3")
*!*			   SQLDISCONNECT(fl_kon)
*!*			   nilai=0
*!*		ENDIF
*!*	ENDIF 
*!*	RETURN nilai

*!*	FUNCTION f_konek2(p_para1,p_para2,p_para3)
*!*	nilai=1
*!*	fl_kon=SQLCONNECT('aa','support','q211197',.t.)
*!*	IF fl_kon>0 &&
*!*		IF PCOUNT()<=2 && without cursor
*!*			   SQLEXEC(fl_kon,"&p_para2")
*!*			   SQLDISCONNECT(fl_kon)
*!*			   nilai=0
*!*		ELSE
*!*			   SQLEXEC(fl_kon,"&p_para2","&p_para3")
*!*			   SQLDISCONNECT(fl_kon)
*!*			   nilai=0
*!*		ENDIF
*!*	ENDIF 	
*!*	RETURN nilai

FUNCTION Rf_SayRp(x_str)
t_str=alltrim(str(abs(x_str)))
if t_str="0"
   return("")
endif
kalimat=" "
DECLARE sep[5]
sep[1]=''
sep[2]=' Ribu'
sep[3]=' Juta'
sep[4]=' Milliard'
sep[5]=' Triliyun'
nil0=''
nil1=' Satu'
nil2=' Dua'
nil3=' Tiga'
nil4=' Empat'
nil5=' Lima'
nil6=' Enam'
nil7=' Tujuh'
nil8=' Delapan'
nil9=' Sembilan'
******Makin' everything's standard *****
t_bagi_3=INT(LEN(t_str)/3)
IF t_bagi_3<>0
   IF LEN(t_str)%3=0
      t_nil_sep=t_bagi_3
   ELSE
      t_nil_sep=t_bagi_3+1
      t_str=STUFF(t_str,1,0,REPLICATE('0',3-(LEN(t_str)%3)))
   ENDIF
ELSE
   t_str=STUFF(t_str,1,0,REPLICATE('0',3-(LEN(t_str)%3)))
   t_nil_sep=1
ENDIF
********Start readin'*********
t_counter=1
t_baca=1
t_baca_tmp=SPACE(3)
DO WHILE t_nil_sep>=1
   t_baca_temp=SUBSTR(t_str,t_baca,3)
   t_counter2=1
   DO WHILE t_counter2<=3
      x_counter2=ltrim(str(t_counter2))
      baca&x_counter2=SUBSTR(t_baca_temp,t_counter2,1)
      t_counter2=t_counter2+1
   ENDDO
   DO CASE
   CASE baca1='0'
      kalimat=kalimat+nil&baca1
   CASE baca1='1'
      kalimat=kalimat+' Seratus'
   CASE baca1<>'1' .and. baca1<>'0'
      kalimat=kalimat+nil&baca1+' Ratus'
   ENDCASE
   DO CASE
   CASE baca2='1' .and. baca3='0'
      kalimat=kalimat+' Sepuluh'
   CASE baca2='1' .and. baca3='1'
      kalimat=kalimat+' Sebelas'
   CASE baca2='1' .and. baca3>'1'
      kalimat=kalimat+nil&baca3+' Belas'
   CASE baca2>'1' .and. baca3='0'
      kalimat=kalimat+nil&baca2+' Puluh'
   CASE baca2>'1' .and. baca3>'0'
      kalimat=kalimat+nil&baca2+' Puluh'+nil&baca3
   CASE baca2='0'
      IF  t_nil_sep=2 .and. baca3='1'             && for one hundred
         IF baca1 <>'0'
            kalimat=kalimat+' Satu Ribu'
         ELSE 
            kalimat=kalimat+' Seribu'
         ENDIF 
         t_nil_sep=t_nil_sep-1
         t_baca=t_baca+3
         LOOP 
      ELSE 
         kalimat=kalimat+nil&baca3
      endif
   ENDCASE 
   if t_bagi_3=0
      exit
   endif
   if t_baca_temp<>'000'            && If the rest's nul 'n' nothing's written
   kalimat=kalimat+sep[t_nil_sep]
   endif
   t_nil_sep=t_nil_sep-1
   t_baca=t_baca+3
ENDDO
kalimat=kalimat+' Rupiah'
return(kalimat)


FUNCTION KUNCI(p_param,p_paramb)
  LOCAL hasil,v_buff,v_buffer,v_teks
  hasil=.f.
  if file(p_param)
     v_teks=iif(p_paramb,chr(26),chr(3))
     v_buff=fopen(p_param,2)
     v_buffer=fread(v_buff,1)
     fseek(v_buff,0)
     if v_buffer$chr(3)+chr(4)+chr(26)+CHR(48)
        fwrite(v_buff,v_teks)
        hasil=.T.
     endif
     fclose(v_buff)
  ENDIF
  return(hasil)
ENDFUNC 

FUNCTION REC_LOCK(wait)
   PUBLIC forever
   if rlock()
     return (.t.)		&& LOCKED
   ENDIF
   forever = (wait = 0)
   do while (FOREVER .or. WAIT > 0)
      if rlock()
         return (.t.)		&& LOCKED
      endif
      inkey(.5)			&& WAIT 1/2 SECOND
      wait = wait - .5
   enddo
   return (.f.)			&& NOT LOCKED
ENDFUNC 

FUNCTION dKooyaaNo(MMYY)
IF !FILE(fd_trs+ "NO"+mmyy+".DBF")
   CREATE TABLE (fd_trs+"NO"+mmyy+".DBF");
   (  NOTRANS c(2),  NOMOR N(10))      
   INDEX on NOTRANS TAG NOMMYY1
    INSERT INTO ;
     (fd_trs+"NO"+mmyy+".DBF") ;
   VALUES;
     ('IN',0)
   INSERT INTO ;
     (fd_trs+"NO"+mmyy+".DBF") ;
   VALUES;
     ('RC',0)
   INSERT INTO ;
     (fd_trs+"NO"+mmyy+".DBF") ;
   VALUES;
     ('PO',0)    
   INSERT INTO ;
     (fd_trs+"NO"+mmyy+".DBF") ;
   VALUES;
     ('BR',0)
  INSERT INTO ;
     (fd_trs+"NO"+mmyy+".DBF") ;
   VALUES;
     ('SR',0)     
   INSERT INTO ;
     (fd_trs+"NO"+mmyy+".DBF") ;
   VALUES;
     ('PR',0)   
   USE
ENDIF

ENDFUNC 
*
FUNCTION netto(dval,disc1,disc2,disc3,disc4)
 LOCAL detail1,detail2
 detail1 =(dval-disc4)*(1-(disc3/100))
 detail2=detail1*(1-(disc1/100))
 RETURN detail2*(1-(disc2/100))
ENDFUNC 

FUNCTION totald(dval,disc3,disc4)
 RETURN (dval-disc4)*(1-(disc3/100))
ENDFUNC 

FUNCTION disc1(subtot,disc1)
 RETURN subtot*(disc1/100)
ENDFUNC 

FUNCTION disc2(subtot,disc1,disc2)
 RETURN subtot*(1-(disc1/100))*(disc2/100)
ENDFUNC 

FUNCTION qty(qcrt,qbox,qpcs,itemkbox,itembpcs)
RETURN (qcrt*itemkbox*itembpcs)+(qbox*itembpcs)+qpcs
ENDFUNC 

Function CBP(Pieces,kem_1,kem_2)
_k = int(Pieces/(kem_1*kem_2))
_b = int( (Pieces- (_k*kem_1*kem_2) ) /kem_2)
_p = Pieces - (_k*kem_1*kem_2) - (_b*kem_2)
return(transform(_k,'9,999')+'/'+transform(_b,'999')+'/'+transform(_p,'999'))
              *  M_BAL  M_CRT  M_BOX           1BAL  1CRT    1BOX    1PCS
*Function CBP2 // 1BL=2C,1C=3BX,1BX=5PC =       ((((1*2)+1)*3)+1)*5)+1=51
*              // QBAL*M_BAL=Z,     (1*2)  =2   
*              // (QCRT+Z)*M_CRT=Y  (1+2)*3=9
*              // (QBOX+Y)*M_BOX=X  (1+9)*5=50
*              // QPCS+X        =   (1+50) =51
*              // ((((Qbal*M_BAL)+Qcrt)*M_CRT)+Qbox)*M_BOX)+Qpcs
*Param Pieces,kem_1,kem_2
*_k = int(INT(Pieces)/(kem_1*kem_2))
*_b = int( (INT(Pieces)- (_k*kem_1*kem_2) ) /kem_2)
*_p = Pieces - (_k*kem_1*kem_2) - (_b*kem_2)
*return(transf(_k,'9999')+' '+transf(_b,'999')+' '+transf(_p,'999.99'))

FUNCTION mon29char(dates)
LOCAL abjad
               * 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   abjad="         JANUARI  FEBRUARI MARET    APRIL    MEI      JUNI     JULI     AGUSTUS  SEPTEMBEROKTOBER  NOVEMBER DESEMBER "
   return(SUBSTR(abjad,(dates*9)+1,9))

Function USERENC(MnCoDe)
* Syntax  : Code(<expC1>)
* Return  : expC1 encoded form
LOCAL MCODE,Mi
 MCODE = ''
 Mi = 1
 do while Mi <= len(trim(MnCoDe))
    Mcode = Mcode + str(ASC(SUBSTR(MnCoDe,Mi,1))+99,3)
    Mi = Mi + 1
 enddo

retuRN MCODE

Function USERDEC(MnCoDe)
* Syntax  : DeCode(<expC1>)
* Return  : expC1 Decoded form
 LOCAL MCODE,Mi
 MCODE = ''
 Mi = 1
 do while Mi <= len(trim(MnCoDe))
    MCoDe = MCoDe + CHR(val(subsTR(MnCode,Mi,3))-99)
    Mi = Mi + 3
 enddo

retuRN MCODE

FUNCTION d2char(dtval,sts)
PRIVATE rtval
IF sts=.t.
   rtval=SUBSTR(DTOC(dtval),1,2)+SUBSTR(DTOC(dtval),4,2)+SUBSTR(DTOC(dtval),9,2)
ELSE
   rtval=SUBSTR(DTOC(dtval),4,2)+SUBSTR(DTOC(dtval),9,2)
ENDIF 
RETURN rtval

FUNCTION rpbln(bln,tipe)
DO CASE 
fl_qty=0
CASE tipe=1
	fl_qty=b_dawl-b_kawl
	IF VAL(bln)>=1
		FOR i=1 TO VAL(bln)
			mi_i=REPLICATE('0',2-LEN(ALLTRIM(STR(i))))+ALLTRIM(STR(i))
			fl_qty=fl_qty+b_d&mi_i-b_k&mi_i
		NEXT 
	ENDIF 
CASE tipe=2
	fl_qty=b_d&bln
CASE tipe=3
	fl_qty=b_k&bln
ENDCASE 
return(fl_qty)
ENDFUNC 

FUNCTION rpbln2(bln,tipe)
DO CASE 
fl_qty=0
CASE tipe=1
*	fl_qty=b_dawl-b_kawl
	IF VAL(bln)>=1
		FOR i=1 TO VAL(bln)
			mi_i=REPLICATE('0',2-LEN(ALLTRIM(STR(i))))+ALLTRIM(STR(i))
			fl_qty=fl_qty+cmd&mi_i-cmk&mi_i
		NEXT 
	ENDIF 
CASE tipe=2
	fl_qty=b_d&bln
CASE tipe=3
	fl_qty=b_k&bln
ENDCASE 
return(fl_qty)
ENDFUNC 

FUNCTION hitbal2()
aa=RECNO()
SUM lg_rpd-lg_rpk for RECNO()<aa TO bb
GOTO aa
RETURN (bb+lg_rpd-lg_rpk)
ENDFUNC 



FUNCTION Rf_HitBln(bln)
fl_qty=b_awl
FOR i=1 TO VAL(bln)
	fl_i=REPLICATE('0',2-LEN(ALLTRIM(STR(i))))+ALLTRIM(STR(i))
	fl_qty=fl_qty+b_&fl_i
NEXT 
return(fl_qty)
ENDFUNC 

FUNCTION strzero(nilai,panjang)
RETURN (REPLICATE('0',panjang-LEN(ALLTRIM(STR(nilai))))+ ALLTRIM(STR(nilai)))


FUNCTION Rf_StrZero(angka,lebar)
return(REPLICATE('0',lebar-LEN(ALLTRIM(STR(angka))))+ALLTRIM(STR(angka)))
ENDFUNC 

FUNCTION Rf_QDay(hari)
RETURN DAY(DATE(YEAR(GOMONTH(hari,1)),MONTH(GOMONTH(hari,1)),1)-1)
ENDFUNC 

FUNCTION Rf_LDay(tanggal)
fl_period=Rf_D2Char(tanggal,.f.)
fl_mon=Rf_StrZero(MONTH(tanggal),2)
fl_yer=Rf_StrZero(YEAR(tanggal),4)
RETURN (CTOD(Rf_StrZero(Rf_QDay(tanggal),2)+'-'+fl_mon+'-'+fl_yer))
ENDFUNC 

FUNCTION Rf_D2Char(dtval,sts)
PRIVATE rtval
IF sts=.t.
   rtval=SUBSTR(DTOC(dtval),1,2)+SUBSTR(DTOC(dtval),4,2)+SUBSTR(DTOC(dtval),9,2)
ELSE
   rtval=SUBSTR(DTOC(dtval),4,2)+SUBSTR(DTOC(dtval),9,2)
ENDIF 
RETURN rtval

FUNCTION Rf_DoConnect()

  	fc_kon = "driver=mysql odbc 5.1 driver;server=localhost;uid=root;pwd=CARDO;database=glba"
  	fv_ip='Localhost'
  	fv_tipe='3'
fv_kon=SQLSTRINGCONNECT("&fc_kon")
ENDFUNC 

FUNCTION Rf_Connect(nilai)
vt_ok=0
IF nilai=1
	IF MESSAGEBOX('Reconnect to server ?', 4 + 16 + 256,'Konfirmasi')=6
		Rf_DoConnect()
		SQLEXEC(fv_kon,"kill ?fv_ckon")		    
	ELSE 
		vt_ok=1	
	ENDIF 	
ELSE 
    Rf_DoConnect()
ENDIF 
IF vt_ok=0		
	strsql="select connection_id() as concob"
	coba='curcoba'
	vt_ok=0
	IF SQLEXEC(fv_kon,strsql,coba)<0
	   vt_ok=1
	ELSE  	
		SELECT curcoba
		fv_ckon=concob
	ENDIF 	 
	IF vt_ok>0
		MESSAGEBOX('Gagal koneksi ke server..Error ('+TRANSFORM(vt_ok,"9")+')',0,fv_pesan)
	ENDIF 	 	
ENDIF 	
RETURN 
ENDFUNC 
