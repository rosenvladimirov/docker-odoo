#!/bin/bash

array_contains () {
    local array=('setup' '.git' '.idea')
    local seeking=$1
    local in=1
    for element in "${array[@]}"; do
echo "$DEST/$element = > $seeking"
        if [ "$DEST/$element" == "$seeking" ]; then
            in=0
            break
        fi
    done
    return $in
}

SOURCE="/opt/odoo-11.0"
DEST="/var/lib/odoo/.local/share/Odoo/addons/11.0"

filename=$SOURCE/$1
direname=$SOURCE/$2
maxdepth=$3

IFS=$'\n'
find -maxdepth 3 -type d | sed 's|./||' >> $filename

for next in `cat $filename`
do
#    echo "$SOURCE/$next read from $filename"
    if array_contains $next; then
	echo "skipped $next" >> $SOURCE/skip.txt
    else
	ln --symbolic $SOURCE/$next $DEST/ 2>&1 | tr '‘' '|' | cut -d "|" -f 4 | tee -a $SOURCE/err.txt
    fi
done

find -maxdepth 2 -type d | sed 's|.||' >> $direname
for next in `cat $direname`
do
    TEST=$next
    echo "$DEST/${TEST##*/} read from $direname"
    rm -rf $DEST/${TEST##*/}
done
# force remove .git .tx setup
rm -f $DEST/setup
rm -f $DEST/.git
rm -f $DEST/.tx

#for next in `cat $SOURCE/err.txt`
#do
#    echo "$SOURCE/$next read from $direname"
#    nextgrep = `echo $next | sed 's|./||'`
#    find -maxdepth 2 -type d | grep $nextgrep >> dublicate.txt
#done
exit 0
