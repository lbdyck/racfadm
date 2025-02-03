/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Edit Macro - Message about RACRUN             */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This edit macro is used by all REXX programs         */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A1  250202  LBDYCK   Add text2 message                            */
/* @A0  250120  TRIDJK   Created REXX                                 */
/*====================================================================*/
Address ISRedit
'MACRO'
text1  = 'Edit macro RACRUN can be used run RACF commands in foreground'
text2  = 'Enter RACRUN ? for RACRUN help.'
"line_before .zfirst = msgline  '"text1"'"
"line_before .zfirst = msgline  '"text2"'"
exit
