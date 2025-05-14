** FIND     RACFCLSG
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
             call RACFPROF 'DATASET' dataset
             call RACFALTD dataset
             call RACFPROF 'GROUP' id
             call RACFUSR id
             call RACFGRP id

** FIND     RACFGRP
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
