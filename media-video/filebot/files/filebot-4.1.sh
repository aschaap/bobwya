#!/bin/env bash

java -Dunixfs=false -Xmx256m -Dapplication.update=skip -Dapplication.deployment=portable -DuseExtendedFileAttributes=true -DuseCreationDate=false -Dfile.encoding="UTF-8" -Dsun.jnu.encoding="UTF-8" -Dapplication.dir="${HOME}/.filebot" -Djava.io.tmpdir="${HOME}/.filebot/temp" -Djna.library.path="/usr/share/filebot/lib/" -Djava.library.path="/usr/share/filebot/lib/" -Dsun.net.client.defaultConnectTimeout=5000 -Dsun.net.client.defaultReadTimeout=25000 -jar "/usr/share/filebot/lib/FileBot.jar" "$@"
