/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM  -  PWDPHR  -  Menu Option P                    */
/*                                                                    */
/*  Function:  The RACFPWPH exec is used to display the               */
/*             PASSWORD and PASSPHRASE settings for all               */
/*             userids.                                               */
/*                                                                    */
/*  Use:       RACFPWPH userid                                        */
/*                                                                    */
/*             Note: if userid not specified, then all userids        */
/*                                                                    */
/*  Author:    Janko Kalinic                                          */
/*             The ISPF Cabal - Vive la revolution                    */
/*             the.pds.command@gmail.com                              */
/*                                                                    */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/*      240419  LBD      Modified for use under ISPF                  */
/*      240418  JK       Creation                                     */
/*--------------------------------------------------------------------*/
  arg userid
  parse value '' with null
  if userid = null then
  userid = '**'
  x = outtrap("search.")
  if sysvar('sysispf') = 'ACTIVE'
     then do
          ispf = 1
          report.1 = left('Userid',10) left('Password',10) 'PassPhrase'
          report.0 = 1
          if userid = '**' then do
             Address ISPExec
             'addpop row(6) column(4)'
             'display panel(racfppp)'
             xrc = rc
             'rempop'
             if xrc > 0 then exit
             Address TSO
             end
          end
     else ispf = 0
  Address TSO
  "search filter("userid") class(user)"
  x = outtrap("off")
  do n = 1 to search.0
    userid = strip(left(search.n,8))
    call xutil
  end
  if ispf = 1 then do
     ddn = 'RA'time('s')
     'alloc f('ddn') new spa(15,15) tr recfm(v b)' ,
        'lrecl(84) blksize(0) unit(sysda)'
     'execio * diskw 'ddn' (finis stem report.'
     address ispexec
     "lminit dataid(rapwph) ddname("ddn")"
     "view dataid("rapwph")"
     'lmfree dataid('rapwph')'
     end
  exit
xutil:
  rxrc=IRRXUTIL("EXTRACT","USER",userid,"RACF")
  if (word(rxrc,1) <> 0) then do
    say 'IRRXUTIL return code:'rxrc
    exit
  end
  if word(userid racf.base.haspwd.1,2) = 'TRUE' then
  pswd = 'PASSWORD'
  else
  pswd = 'NOPASSWORD'
  if word(userid racf.base.hasphras.1,2) = 'TRUE' then
  phrs = 'PASSPHRASE'
  else
  phrs = 'NOPASSPHRASE'
  if ispf = 0
     then say left(userid,8) left(pswd,10) left(phrs,12)
     else do
          c = report.0 + 1
          report.c = left(userid,10) left(pswd,10) left(phrs,12)
          report.0 = c
          end
  return
