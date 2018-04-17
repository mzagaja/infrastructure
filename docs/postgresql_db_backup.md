# PostgreSQL Database Backup
*Org: @MAPC*
*Author: @iangmhill*

In order to backup our production database, the MAPC Digital Services Working Group setup a simple `pg_dumpall` cron task which dumps all of the databases in both of our PostgreSQL servers, compresses the resulting data into TAR files, and uploads them to a Amazon S3 bucket.

## Background

Our production database server is an Amazon EC2 instance that we commonly refer to as `db.live`. In order to support older systems whose data has not yet been migrated, `db.live` hosts two versons of PostgreSQL, 9.3 and 9.5. Unsurprisingly, our goal was to backup both database servers, so we could revive `db.live` if it ever went offline.

## Step-by-step

Setting up the backup of `db.live` generally required 3 tasks. Creating a backup user that can read all of the databases on both servers, setting up a private S3 bucket for the backups, and finally creating a cron task to automate the process on a regular basis.

### 1. Backup User

In order to backup all of the databases on both servers, we needed a user with the permissions to read *everything*. We originally attempted to create a normal user and assign all of the appropriate privileges to that user; however, it was unclear how to assign read privileges to the PostgreSQL System Catalogs which store the server's permissioning and sensitive settings. Ultimately we decided to create a read-only super user to perform the backups.

Using the `postgres` user in **both PostgreSQL servers**:

```
=# CREATE USER pgbackup SUPERUSER password '<PASSWORD>';
=# ALTER USER pgbackup set default_transaction_read_only = on;
```

NOTE: It was important that the same user exist in both database servers to make backing up easier (and so the database users could share the same linux user).

We also need to create a matching linux user on the `db.live` EC2 instance.

```
$ sudo useradd pgbackup
```

### 2. S3 Bucket

The most straightforward step in setting up automated backups was the creation of the S3 bucket. If you've created one before, there's nothing special here.

1. Navigate to the S3 home page which lists all of your S3 buckets.
2. Click **Create bucket** and use the default private settings. We named our bucket `db.live.backup`.

We then set up a write-only S3 IAM user so the cron task can directly upload the TAR files. We used the following IAM policy for the IAM user.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject*"
            ],
            "Resource": "*"
        }
    ]
}
```

### 3. Cron Task

Finally, to tie all of this together, we needed to set up the cron task that would run the backup automatically for us. Cron tasks often run as root, but since the root account does not match the PostgreSQL account, authentication fails. Therefore, the cron task needs to be run as the `pgbackup` user.

In order to run `pg_dumpall` programatically without specifying a password, we need to use the --no-password flag and leave the password in a `.pgpass` file in the home directory of the `pgbackup` user. For us, the `.pgpass` file contained:

```
localhost:5432:*:pgbackup:<PASSWORD>
localhost:5433:*:pgbackup:<PASSWORD>
```

NOTE: Given that `.pgpass` contains passwords, it should not be visible to any other users. Run the following on `.pgpass`:

```
$ chmod 600 ~/.pgpass
```

We created two cron scripts to backup our data - one for the daily backups and one for the weekly backups. (Realistically, we probably could have combined them if we really wanted to.)

The `/etc/cron.backupdb.daily` script:

```
#!/bin/bash
BUCKET=db.live.backup
DIRECTORY=/home/pgbackup

# Backup Postgres 9.3
EXPORTFILE=server93-`date +%A`.sql
COMPRESSEDFILE=${EXPORTFILE}.tgz

/usr/lib/postgresql/9.5/bin/pg_dumpall -f $DIRECTORY/$EXPORTFILE -c --no-password --username=pgbackup --port=5432
tar -czf $DIRECTORY/${COMPRESSEDFILE} $DIRECTORY/${EXPORTFILE}

s3cmd put $DIRECTORY/${COMPRESSEDFILE} s3://${BUCKET} --access_key=<IAM_ACCESS_KEY> --secret_key=<IAM_SECRET_KEY>

rm $DIRECTORY/$EXPORTFILE $DIRECTORY/$COMPRESSEDFILE

# Backup Postgres 9.5
EXPORTFILE=server95-`date +%A`.sql
COMPRESSEDFILE=${EXPORTFILE}.tgz

/usr/lib/postgresql/9.5/bin/pg_dumpall -f $DIRECTORY/$EXPORTFILE -c --no-password --inserts --username=pgbackup --port=5433
tar -czf $DIRECTORY/${COMPRESSEDFILE} $DIRECTORY/${EXPORTFILE}

s3cmd put $DIRECTORY/${COMPRESSEDFILE} s3://${BUCKET} --access_key=<IAM_ACCESS_KEY> --secret_key=<IAM_SECRET_KEY>

rm $DIRECTORY/$EXPORTFILE $DIRECTORY/$COMPRESSEDFILE
```

And the `/etc/cron.backupdb.weekly` script:

```
#!/bin/bash
BUCKET=db.live.backup
DIRECTORY=/home/pgbackup

# Backup Postgres 9.3
EXPORTFILE=server93-weekly-`date +%V`.sql
COMPRESSEDFILE=${EXPORTFILE}.tgz

/usr/lib/postgresql/9.5/bin/pg_dumpall -f $DIRECTORY/$EXPORTFILE -c --no-password --username=pgbackup --port=5432
tar -czf $DIRECTORY/${COMPRESSEDFILE} $DIRECTORY/${EXPORTFILE}

s3cmd put $DIRECTORY/${COMPRESSEDFILE} s3://${BUCKET} --access_key=<IAM_ACCESS_KEY> --secret_key=<IAM_SECRET_KEY>

rm $DIRECTORY/$EXPORTFILE $DIRECTORY/$COMPRESSEDFILE

# Backup Postgres 9.5
EXPORTFILE=server95-weekly-`date +%V`.sql
COMPRESSEDFILE=${EXPORTFILE}.tgz

/usr/lib/postgresql/9.5/bin/pg_dumpall -f $DIRECTORY/$EXPORTFILE -c --no-password --username=pgbackup --port=5433
tar -czf $DIRECTORY/${COMPRESSEDFILE} $DIRECTORY/${EXPORTFILE}

s3cmd put $DIRECTORY/${COMPRESSEDFILE} s3://${BUCKET} --access_key=<IAM_ACCESS_KEY> --secret_key=<IAM_SECRET_KEY>

rm $DIRECTORY/$EXPORTFILE $DIRECTORY/$COMPRESSEDFILE
```

NOTE: You will need to replace the `<IAM_ACCESS_KEY>` and `<IAM_SECRET_KEY>` placeholders for either of these scripts to work.

Finally, we need to add those scripts to the `/etc/crontab` file so they run automatically.

```
# m h dom mon dow user command
0 1 * * * pgbackup /etc/cron.backupdb.daily
0 1 * * 7 pgbackup /etc/cron.backupdb.weekly
#
```

Running a restore is as simple as:

```
psql -f matt_test_dump.tar postgres 2> postgres_import_errors.log 1> postgres_import_stdout.log
```
