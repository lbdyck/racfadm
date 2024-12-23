/* --------------------  rexx procedure  -------------------- *
 | Name:      LC                                              |
 |                                                            |
 | Function:  The LC edit macro is used to issue a            |
 |            RACDCERT LIST(LABEL('labelname')) ID(userid)    |
 |            for the label at the cursor position.           |
 |                                                            |
 |                                                            |
 | Use:       LC  cursor-->label name                         |
 |                                                            |
 | Author:    Janko Kalinic                                   |
 |            The ISPF Cabal - Vive la revolution             |
 |            the.pds.command@gmail.com                       |
 |                                                            |
 | History:  (most recent on top)                             |
 |            12/18/24 - Creation                             |
 |                                                            |
 * ---------------------------------------------------------- */
Address ISREdit
"isredit macro"

Address ISREDIT "(ln) = LINE .ZCSR"
ln = strip(substr(ln,4,32))

Address ISREDIT "find 'User:' prev"
Address ISREDIT "(user) = LINE .ZCSR"
id = strip(substr(user,7,8))

x = outtrap('cmd.')
Address TSO "racdcert list(label('"ln"')) id("id")"
x = outtrap('off')
call view_info
exit

/*--------------------------------------------------------------------*/
/*  View information                                                  */
/*--------------------------------------------------------------------*/
view_info:
  ddname = 'racfa'random(0,999)
  address tso "alloc f("ddname") new reuse",
              "lrecl(80) blksize(0) recfm(f b)",
              "unit(vio) space(1 5) cylinders"
  address tso "execio * diskw "ddname" (stem cmd. finis"
  drop rec.
  address ispexec
  "lminit dataid(cmddatid) ddname("ddname")"
  "view dataid("cmddatid")"
  address tso "free fi("ddname")"
return
