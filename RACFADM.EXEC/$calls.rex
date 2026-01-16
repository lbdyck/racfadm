** FIND     RACFCERT
             call RACFVUE  parm seq

** FIND     RACFCLSG
             call RACFCOPC rclass clss_taba
             call RACFPROF rclass profile
             call RACFALTR rclass profile
             call RACFCOPR rclass profile
             call RACFPROF 'GROUP' ID
             call RACFUSR id
             call RACFGRP id

** FIND     RACFCLSR
             call RACFCLSG class '**' 'YES'
             call RACFLOG $CLASSES
             call RACFPROF '_SETROPTS' '_SETROPTS' parm
             call RACFCLSG class '**' 'YES'

** FIND     RACFDSN
             call RACFCOPD dsns_taba
             call RACFPROF 'DATASET' dataset
             call RACFALTD dataset
             call RACFPROF 'GROUP' id
             call RACFUSR id
             call RACFGRP id

** FIND     RACFGEN
             call RACFGENA

** FIND     RACFGRP
             call RACFCOPG groups_taba
             call RACFUSRX group JCC
             call RACFUSRY group
             call RACFALTG group
             call RACFPROF 'GROUP' group
             call RACFPROF 'USER' id
             call RACFUSR id
             call RACFCLSS id
             call RACFUSRX id JCC
             call RACFUSRY id

** FIND     RACFOMVS
             call RACFMVS MVSPRM

** FIND     RACFRING
             call racfring user ring

** FIND     RACFUSR
             call RACFCOPI users_taba
             call RACFCHKP DATEPASS INTPASS DATEPHRS LID
             call RACFALTU parm
             call RACFLOG $undoc
             call RACFCERT user
             call RACFRING user
             call RACFCOPU user name
             call RACFCHKP DATEPASS INTPASS DATEPHRS USER
             call RACFPROF 'USER' user
             call RACFCLSS user
             call RACFUSRX user
             call RACFUSRX user JCC
             call RACFUSRY user
             call RACFALTU user
             call RACFPROF 'GROUP' id
             call RACFGRP id
