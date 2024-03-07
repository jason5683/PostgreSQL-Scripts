SHOW hba_file

psql -c "show hba_file";

select * 
from pg_hba_file_rules 
where address in ('10.33.19.35', '10.33.19.36');

host  all   jlove       10.33.19.197/32 md5

sudo -su postgres

```
/usr/pgsql-11/bin/pg_ctl -D /var/lib/pgsql/11/data/ reload
```

```
db-access-01.twa.ateb.com
```19

-- host    all         jlove       172.16.254.132/32 md5
-- host    all         jlove       10.33.19.197/32 md5

