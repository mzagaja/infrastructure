# Updating PrQL

```sh
# From local machine

ssh prql@prql.mapc.org


# On prql.mapc.org

## Pull new version and compile new binaries
cd prql
git pull
make with-docker ARCH=linux/amd64

## Install new version
sudo cp build/prql-linux-amd64 $(which prql)
sudo cp build/prqld-linux-amd64 $(which prqld)

## Restart prqld
sudo systemctl restart prqld
```
