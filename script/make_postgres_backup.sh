#!/bin/bash

t=$(date +%s)
path="/root/postgres_backups"

dokku postgresql:dump ongakuryoho > $path/ongakuryoho-$t.sql
s3cmd put $path/ongakuryoho-$t.sql s3://ongaku-ryoho-backups/ongakuryoho-$t.sql
