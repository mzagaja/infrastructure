# Postgres on MacOS

TL;DR If you cannot upgrade Postgres locally you can run:

```sh
rm -rf (brew --prefix)/var/postgres && \
initdb (brew --prefix)/var/postgres -E utf8 && \
brew services restart postgresql && \
createdb (whoami)
```

## PostGIS and Homebrew
Due to a [bug with Postgresql homebrew formula](https://github.com/Homebrew/homebrew-core/issues/60686)
upgrading Postgres on MacOS often fails with major versions if you use PostGIS.
Until the formula is updated you'll need to do a [manual upgrade](https://github.com/Homebrew/homebrew-core/issues/60686#issuecomment-811270465)
or run the command at the top of this document to clear out your old version.

## Socket Connection
On a remote host you can setup a TablePlus connection via socket using a local
socket.

Host/Socket: `/var/run/postgresql`

On MacOS local you can use

Host/Socket: `/tmp`
