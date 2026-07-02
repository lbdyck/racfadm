/* --------------------  rexx procedure  -------------------- *
 | Name:      LC                                              |
 |                                                            |
 | Function:  The LC edit macro is used to issue a            |
 |            RACDCERT LIST(LABEL('labelname')) ID(userid)|   |
 |            CERTAUTH|SITE for the label line at the         |
 |            cursor position.                                |
 |                                                            |
 | Use:       LC  cursor-->label line                         |
 |                                                            |
 | Author:    Janko Kalinic                                   |
 |            The ISPF Cabal - Vive la revolution             |
 |            the.pds.command@gmail.com                       |
 |                                                            |
 | History:  (most recent on top)                             |
 |            06/24/26 - Process GETCERTS RINGS input         |
 |            02/09/26 - Process VUECERTS INDEX input         |
 |            01/22/26 - Process CERTAUTH/SITE certificates   |
 |            12/18/24 - Creation                             |
 |                                                            |
 * ---------------------------------------------------------- */
Address ISREdit
"isredit macro"

Address ISREDIT "(ln) = LINE .ZCSR"
if substr(ln,3,3) = 'ID(' |,            /* GETCERTS RINGS format */
   substr(ln,3,3) = 'CER' |,
   substr(ln,3,3) = 'SIT' then do
  parse var ln .
  parse var ln with "'" lab "'" .
  lab = strip(lab)
  lab = strip(lab,,"'")
  id  = substr(ln,3,12)
  call List_label
  exit
  end

if left(ln,3) = '01 ' then do           /* VUECERTS INDEX format */
  parse var ln . id stdate endate status . . lab
  lab = strip(lab)
  lab = strip(lab,,"'")
  call List_label
  exit
  end

if substr(ln,37,4) = 'OWN=' then do   /* RACFUSR RINGS format */
  lab = strip(substr(ln,4,32))
  id  = strip(substr(ln,41,12))
  call List_label
  exit
  end

if substr(ln,37,3) = 'ST=' then do    /* RACFUSR CERTS format */
  lab = strip(substr(ln,4,32))
  Address ISREDIT "find 'User:' prev"
  Address ISREDIT "(user) = LINE .ZCSR"
  id = "id("strip(substr(user,7,8))")"
  call List_label
  exit
  end

List_label:
x = outtrap('cmd.')
Address TSO "racdcert list(label('"lab"'))" id
x = outtrap('off')
call view_info
return

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
