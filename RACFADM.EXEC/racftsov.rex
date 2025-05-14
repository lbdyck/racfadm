/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Trap TSO command output and invoke ISPF View    */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  250508  TRIDJK   AUTHOR: MARK ZELDEN, CBT 434                 */
/*====================================================================*/
parse arg TSOCMD
address ISPEXEC "CONTROL ERRORS RETURN"
address TSO
ddnm = 'DD'||random(1,99999)    /* choose random ddname  */
junk = msg(off)
"ALLOC FILE("||ddnm||") UNIT(VIO) NEW TRACKS SPACE(90,90) DELETE",
" REUSE LRECL(172) RECFM(F B) BLKSIZE(8944)"
junk = msg(on)
/*                                    */
/*  issue tso commnd and trap output  */
/*                                    */
junk=outtrap(LINE.)
TSOCMD
junk=outtrap('off')
/*                                    */
"EXECIO" line.0  "DISKW" ddnm "(STEM LINE. FINIS"
address ISPEXEC "LMINIT DATAID(TEMP) DDNAME("||ddnm||")"
address ISPEXEC "VIEW   DATAID("||temp")"
address ISPEXEC "LMFREE DATAID("||temp")"
junk = msg(off)
"FREE FI("||ddnm||")"
