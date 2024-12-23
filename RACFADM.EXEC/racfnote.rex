/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Edit Macro - Display info for CERTS/RINGS     */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This edit macro is used by all REXX programs         */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  200218  RACFA    Created REXX                                 */
/*====================================================================*/
Address ISRedit
'MACRO'
text1  = 'Edit macro LC can be used to list a certificate'
text2  = '  Place cursor on --->label name and press Enter'
text3  = 'Edit macro LR can be used to list rings for a user'
text4  = '  Place cursor on --->userid and press Enter'
text5  = ' '
"line_after .zfirst = noteline '"text5"'"
"line_after .zfirst = noteline '"text4"'"
"line_after .zfirst = msgline  '"text3"'"
"line_after .zfirst = noteline '"text2"'"
"line_after .zfirst = msgline  '"text1"'"
exit
