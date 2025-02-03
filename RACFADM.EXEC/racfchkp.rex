/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Check the days until the password changes       */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A2  250201  TRIDJK   Support CKPW primary command                 */
/* @A1  250101  TRIDJK   Modified for RACFUSR line command CK         */
/* @A0  200911  LBDYCK   Logon exec                                   */
/*====================================================================*/
Arg padate pdays phdate user
Check_PW:
  expdt  = ''
  if datatype(padate) == 'NUM' then
    pdate = padate
  else if datatype(phdate) == 'NUM' then
    pdate = phdate
  if datatype(pdays) == 'NUM' then do
    pdate = strip(pdate)
    pdate = left(pdate, 2)right(pdate, 3)
    if pdate = 00000 then do
      change = '***'
      call pswd_msg
      exit
      end
    change = date('B', pdate, 'J') + pdays - date('B')
    end
  else
    change = '***'
  if datatype(pdays) /= 'NUM' then do
    call pswd_msg
    exit
    end
  pdate = strip(pdate)
  pdate = left(pdate,2)''right(pdate,3)
  fdate = date('b',pdate,'j') + pdays
  change = fdate - date('b')
  expdt = date('u',fdate,'b')
  call Pswd_msg
  exit
Pswd_msg:
  Address ISPExec
  racflmsg = 'Days until Password Change:' left(change,5) ' Date:' expdt
  if pos('USER=',user) = 0 then   /* CKPW Command?       */
    'setmsg msg(racf011)'         /* No, CK line command */
  else
    'vput (racflmsg)'             /* Yes, do not display */
  return
