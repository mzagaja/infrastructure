# Postgres Server Setup Documentation

## Setup the Server
We used an AWS t2.medium instance since most of the previous database usage has been low CPU with some spikiness to it. We would have done t3.medium but our region did not support it. We setup a 100GB gp2 SSD with it.

```sh
sudo apt-get update
sudo apt-get upgrade -q -y
sudo hostnamectl set-hostname pg.mapc.org
```

Leave timezone as UTC.

### Setup CloudWatch
```sh
mkdir cloudwatch-agent
cd cloudwatch-agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
unzip AmazonCloudWatchAgent.zip
sudo ./install.sh
```

## Install PostgreSQL
[PostgreSQL Documentation](https://www.postgresql.org/download/linux/ubuntu/)

Import the repository signing key, and update the package lists

```sh
sudo apt-get install curl ca-certificates gnupg
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-11
```

### Update Security Configuration to Allow Connections from Outside

Allow outside connections. We are going to let the AWS firewall and security group configuration own the responsibility for preventing outside connections, and let Postgres and the server allow everything through.

[Edit listen_addresses to allow outside connections](https://www.postgresql.org/docs/10/runtime-config-connection.html#RUNTIME-CONFIG-CONNECTION-SETTINGS)

```sh
sudo vi /etc/postgresql/11/main/postgresql.conf
```

[Edit pg_hba.conf to allow outside connections](https://www.postgresql.org/docs/11/auth-pg-hba-conf.html)

```sh
sudo vi /etc/postgresql/11/main/pg_hba.conf
sudo systemctl restart postgresql@11-main
```

## Install PostGIS 3.0.1

### Requirements
- GEOS 3.8.0
- SFCGAL 1.3.7
- GDAL 3.0.4
- PROJ 6.3.1
- protobuf-c 1.3.3
- json-c 0.13.1

```sh
sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt-get update
# install PROJ
sudo apt-get install libproj-dev proj-data proj-bin -y
# install GEOS
sudo apt-get install libgeos-dev -y
# install GDAL
sudo apt-get install libgdal-dev python3-gdal gdal-bin -y
# install SFCGAL
sudo apt-get install libsfcgal-dev sfcgal-bin -y
# install protobuf-c
sudo apt-get install protobuf-c-dev protobuf-c-compiler
# install json-c
sudo apt-get install libjson0 libjson0-dev
```

### Install PostGIS
```sh
sudo apt-get install postgresql-11-postgis-3 postgresql-11-postgis-3-dbgsym postgresql-11-postgis-3-scripts -y
```

```sql
-- installs geometry and geography support
CREATE EXTENSION postgis;
-- install these if you need them
CREATE EXTENSION postgis_raster;
CREATE EXTENSION postgis_topology;
-- 3d and advanced processing
CREATE EXTENSION postgis_sfcgal;
-- street address normalization
CREATE EXTENSION address_standardizer;
-- geocoder/reverse_geocoder for US census data
CREATE EXTENSION postgis_tiger_geocoder CASCADE;
```

## PostGIS Database Migration Instructions
[PostGIS Hard Upgrade](https://postgis.net/docs/manual-3.0/postgis_installation.html#hard_upgrade)

`pg_dump -Fc -b dbname > filename`

* -b includes binary blobs per PostGIS documentation recommendation.

Create the postgres role/user for the database:

```sh
createuser --createdb --pwprompt dbname
psql -d database -c “CREATE EXTENSION postgis;”
createdb --owner=OWNER database
```

Then we restore the database.

For PostGIS enabled databases
```sh
psql -d database -c “CREATE EXTENSION postgis;”
# optional if you need legacy function support
psql -d [yourdatabase] -f legacy.sql
perl utils/postgis_restore.pl "/somepath/olddb.backup" | psql -h localhost -p 5432 -U postgres newdb 2> errors.txt
```

For non-PostGIS enabled databases
```sh
pg_restore -v -j 2 -O -x -no-data-for-failed-tables --schema=tabular -d ds filename
```

* -j number of vCPus for number of jobs
* -O no owner. We need to make an owner for each database.
* -v verbose
* -x No access privileges restored
* --no-data-for-failed-tables to avoid restoring auxiliary tables

## Update applications to point to updated database.
