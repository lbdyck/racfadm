/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Edit Macro - Position to class in $CLASSES    */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This edit macro is used by RACFLOG exec              */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  260305  TRIDJK   Created REXX                                 */
/*====================================================================*/
Address ISREdit
"isredit macro"
Address ISPExec "vget (iclass)"
Address ISREdit "find "iclass" 3"
exit
