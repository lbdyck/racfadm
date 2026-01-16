/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM  -  RACFMAIL                                    */
/*                                                                    */
/*  Function:  The RACFMAIL exec is used to display the               */
/*             DATA field which has the email address                 */
/*                                                                    */
/*  Use:       RACFMAIL userid                                        */
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
/*      250331  JK       Creation                                     */
/*--------------------------------------------------------------------*/
  arg userid
  parse value '' with null
  if userid = null then
  userid = '**'
  x = outtrap("search.")
  "search filter("userid") class(user)"
  x = outtrap("off")

  report.0 = 0
  do n = 1 to search.0
    userid = strip(left(search.n,8))
    call xutil
    end

  ddn = 'RA'time('s')
  'alloc f('ddn') new spa(15,15) tr recfm(v b)' ,
     'lrecl(84) blksize(0) unit(sysda)'
  'execio * diskw 'ddn' (finis stem report.'
  address ispexec
  "lminit dataid(racmail) ddname("ddn")"
  "view dataid("racmail")"
  'lmfree dataid('racmail')'
  exit
xutil:
  rxrc=IRRXUTIL("EXTRACT","USER",userid,"RACF")
  if (word(rxrc,1) <> 0) then do
    say 'IRRXUTIL return code:'rxrc
    exit
    end
  if pos('@',racf.base.data.1) > 0 then do
    c = report.0 + 1
    report.c = left(userid,8) strip(racf.base.data.1)
    report.0 = c
    end
  return
