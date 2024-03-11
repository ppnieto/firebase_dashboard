#!/bin/bash

flutter build web --release --no-tree-shake-icons
rsync -i ~/.ssh/id_rsa build/web/* pi@192.168.0.33:/home/pi/vsd
#rsync build/web/* /Users/ppnieto/vsd
#firebase deploy --only hosting
 