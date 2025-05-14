/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - General Command Logger to ZFS file (Prototype)*/
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  050101  Janko    Created REXX                                 */
/*====================================================================*/
TRACE
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

dt = date('J') time()

$path = '/u/tridjk/RACFADM'
"alloc dd(logfile) path('"$path"') pathopts(owronly,oappend,ocreat)",
  "filedata(text),pathmode(sirwxu) lrecl(1024) reuse"

/* Test data */
cmd.1 = dt "RACFADM RC=0 ADDUSER LADY NAME(LADY WHISTLEBLOWER)"
call log_cmd
cmd.1 = dt "RACFADM RC=0 ALTUSER LADY SPECIAL OPERATIONS AUDITOR"
call log_cmd
cmd.1 = dt "RACFADM RC=0",
           "ADDUSER TRIDJKB OWNER(SYS1) PASSWORD(MjWq9cEC)",
           " DFLTGRP(SYS1)",
           " NAME('JANKO')  SPECIAL OPERATIONS GRPACC ROAUDIT",
           " OMVS(HOME('/u/tridjkb')",
           " PROGRAM('/bin/sh') AUTOUID) TSO(PROC(QCBTPROC)",
           " ACCTNUM(1) SIZE(2000000)",
           " UNIT(3390)) DATA('THE.PDS.COMMAND@GMAIL.COM')"
call log_cmd

close:
"free f(logfile)"
exit 0

log_cmd:
cmd.1 = strip(cmd.1)
"execio 1 diskw logfile (finis stem cmd."
return
