#!/bin/bash

COMMENT_STRING="# Commented out by master.sh "
SYBASE_STRING1="syb_dbdump"
SYBASE_STRING2="backup_sybase_translog"
VERSANT_STRING1="backup_versant_db"
VERSANT_STRING2="vrsnt_daily_backup"
# Disable the crons relating to backups
crontab -l > /tmp/cron.tmp
cat /tmp/cron.tmp | sed "s/^[^#]\(.*${SYBASE_STRING1}.*\)/${COMMENT_STRING}\1/g" > /tmp/cron.tmp2
cat /tmp/cron.tmp2 | sed "s/^[^#]\(.*${SYBASE_STRING2}.*\)/${COMMENT_STRING}\1/g" > /tmp/cron.tmp3
rm /tmp/cron.tmp2
mv /tmp/cron.tmp3 /tmp/cron.tmp

cat /tmp/cron.tmp | sed "s/^[^#]\(.*${VERSANT_STRING1}.*\)/${COMMENT_STRING}\1/g" > /tmp/cron.tmp2
cat /tmp/cron.tmp2| sed "s/^[^#]\(.*${VERSANT_STRING2}.*\)/${COMMENT_STRING}\1/g" > /tmp/cron.tmp3
rm /tmp/cron.tmp2
mv /tmp/cron.tmp3 /tmp/cron.tmp

crontab /tmp/cron.tmp
rm /tmp/cron.tmp
