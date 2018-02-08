# Foreign Data Wrappers
Postgres foreign data wrapper allows us to access tables from one database in another database. When the other database updates its table then the same table will be updated in our current database. This means that our data is kept in sync between the two databases. A simple example of how to do this is below:
```SQL
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SERVER dblive95 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'db.live.mapc.org', port '5433', dbname 'postgis');"
CREATE USER MAPPING FOR CURRENT_USER SERVER dblive95 OPTIONS (user '#{Rails.application.secrets.foreign_database_username}', password '#{Rails.application.secrets.foreign_database_password}');"
IMPORT FOREIGN SCHEMA editor LIMIT TO (rpa_poly) FROM SERVER dblive95 INTO public;
```

The end user needs to have a valid username and password for a foreign database role and map it to a current user role in the local database.

This is a great idea in most cases but was not working with geographic data from ESRI ArcSDE.

Trying to use data from ArcSDE formatted geographies is a challenge with Foreign Data Wrappers. The specific error sequence is as follows:

```SQL
IMPORT FOREIGN SCHEMA mapc LIMIT TO (ma_municipalities) FROM SERVER dblive2 INTO public;
```
Returns the error:
```
ERROR:  schema "sde" does not exist
LINE 5:   shape sde.st_geometry OPTIONS (column_name 'shape’)
```
So then attempting to get around it by importing the SDE schema:
```SQL
IMPORT FOREIGN SCHEMA sde FROM SERVER dblive2 INTO sde;
```

```
ERROR:  type "sde.st_geometry" does not exist
LINE 18:   shape sde.st_geometry OPTIONS (column_name 'shape’)

`IMPORT FOREIGN SCHEMA sde FROM SERVER dblive2 INTO sde;`
                 ^
QUERY:  CREATE FOREIGN TABLE gdb_items (
  objectid integer OPTIONS (column_name 'objectid') NOT NULL,
  uuid character varying(38) OPTIONS (column_name 'uuid') COLLATE pg_catalog."default" NOT NULL,
  type character varying(38) OPTIONS (column_name 'type') COLLATE pg_catalog."default" NOT NULL,
  name character varying(226) OPTIONS (column_name 'name') COLLATE pg_catalog."default",
  physicalname character varying(226) OPTIONS (column_name 'physicalname') COLLATE pg_catalog."default",
  path character varying(512) OPTIONS (column_name 'path') COLLATE pg_catalog."default",
  url character varying(255) OPTIONS (column_name 'url') COLLATE pg_catalog."default",
  properties integer OPTIONS (column_name 'properties'),
  defaults bytea OPTIONS (column_name 'defaults'),
  datasetsubtype1 integer OPTIONS (column_name 'datasetsubtype1'),
  datasetsubtype2 integer OPTIONS (column_name 'datasetsubtype2'),
  datasetinfo1 character varying(255) OPTIONS (column_name 'datasetinfo1') COLLATE pg_catalog."default",
  datasetinfo2 character varying(255) OPTIONS (column_name 'datasetinfo2') COLLATE pg_catalog."default",
  definition xml OPTIONS (column_name 'definition'),
  documentation xml OPTIONS (column_name 'documentation'),
  iteminfo xml OPTIONS (column_name 'iteminfo'),
  shape sde.st_geometry OPTIONS (column_name 'shape')
) SERVER dblive2
OPTIONS (schema_name 'sde', table_name 'gdb_items');
CONTEXT:  importing foreign table "gdb_items"
```
The reason for this is that we need the ArcSDE extension installed in our database in order to use the SDE geometry type. To use it in a foreign data wrapper we explored compiling GDAL with ArcSDE support which required the ArcSDE libraries. These are proprietary ESRI libraries we were never able to find. Talking to the folks at ESRI we eventually found the solution at: https://gist.github.com/slibby/b07a5ed4805a21ac22d752b96edca6e7. This solution uses a view and function to convert the ESRI Geometry to WKT
```SQL
-- Create a view of my point FC (sde.locations) that extracts Esri Geometry to WKT
create or replace view connector.locations_wkt as 
    select objectid, sde.ST_AsText(shape)::varchar as geom_wkt from sde.locations;
```

Then we use the foreign data wrapper to create a view and turn WKT back into PostGIS geometry type:
```SQL
--create view in your schema that generates a PostGIS geometry from the WKT text
create or replace view sde_connector.remote_locations_view_pg_geom as select *, public.st_geomfromtext(geom_wkt) as shape from sde_connector.remote_locations_view;

-- create materialized view to make sure all the data is loaded to your new db rather than dynamically querying
create materialized view sde_connector_remote_locations_view_pg_geom_m as select * from sde_connector.remote_locations_view_pg_geom;

select geom_wkt as geom_wkt_from_sde, st_geometrytype(shape) as geom_type_in_postgis, shape as postgis_geometry, st_astext(shape) as geom_wkt_from_postgis from  sde_connector_remote_locations_view_pg_geom_m;
```

If you use a "materialized view" then a copy of the foreign data is stored locally instead of being dynamically queried from the remote database. You need to manually update materialized views. [This StackOverflow article](https://stackoverflow.com/questions/29437650/how-can-i-ensure-that-a-materialized-view-is-always-up-to-date) describes options for trying to keep materialized views updated.

In psql Foreign Data Wrappers can be listed using the command: `\dew+` and user mappings can be listed with `\deu+` while the servers can be listed with `\des+`. 

In a rails application tasks can be added to add and remove foreign data wrappers and tables into `/lib/tasks/db.rake` and then automatically run during `db:setup`

```ruby
Rake::Task["db:create"].enhance do
  Rake::Task["db:add_foreign_data_wrapper_interface"].invoke
  Rake::Task["db:add_rpa_fdw"].invoke
  Rake::Task["db:add_counties_fdw"].invoke
  Rake::Task["db:add_municipalities_fdw"].invoke
  Rake::Task["db:add_tod_service_area"].invoke
  Rake::Task["db:add_neighborhoods_poly"].invoke
end
```

Similarly you may want to add tasks to remove the foreign data wrapper to the `db:drop` command.
