#!/bin/bash
set -e

echo "running id: $(id)" 
# If "-e uid={custom/local user id}" flag is not set for "docker run" command, use 9999 as default
CURRENT_UID=${uid:-9999}
CURRENT_GID=${gid:-9999}
 
# Notify user about the UID selected
echo "Current UID : $CURRENT_UID, Current GID: $CURRENT_GID"
# Create user called "docker" with selected UID
#groupadd -g $CURRENT_GID -r jupyter && useradd --shell /bin/bash -u $CURRENT_UID -o -c "" -g jupyter -m jupyter
#chown jupyter:jupyter /notebooks
 
# Execute process
exec /usr/local/bin/gosu jupyter "$@"