/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Edit Macro - Message about RACRUN             */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This edit macro is used by all REXX programs         */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  250120  TRIDJK   Created REXX                                 */
/*====================================================================*/
Address ISRedit
'MACRO'
text1  = 'Edit macro RACRUN can be used run RACF commands in foreground'
"line_before .zfirst = msgline  '"text1"'"
exit
