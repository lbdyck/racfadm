/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Invoke ISPF View on DSN                         */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  261017  TRIDJK   View dataset                                 */
/*====================================================================*/
parse arg dsn
Address ISPexec "view dataset("dsn")"
exit
