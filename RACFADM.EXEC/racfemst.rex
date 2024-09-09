/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Edit Macro - Position to SETROPTS section     */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This edit macro is used by the RACFPROF exec         */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  240906  TRIDJK   Created REXX                                 */
/*====================================================================*/
ADDRESS ISREDIT                                               /* @A0 */
  "MACRO (PARM) PROCESS"                                      /* @A0 */
  "FIND "parm" 3"                                             /* @A0 */
