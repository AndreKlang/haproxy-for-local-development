#! /bin/bash

# find running containers that use haproxy, and format them into a usable string
LINKS=`docker ps --filter="label=com.evalent.use-haproxy" --format="--link {{.Names}}:{{.Names}}"|tr "\n" " "`

# stop old haproxy
docker rm -f $(docker ps -q --filter="label=com.evalent.is-haproxy") > /dev/null

# start haproxy with links
ID=$(docker run -d $LINKS -p 80:80 --label com.evalent.is-haproxy="" dockercloud/haproxy)

echo "new haproxy is at ip:"
docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $ID

echo "domains managed by haproxy:"
docker ps --filter="label=com.evalent.use-haproxy" --format='{{.Label "com.evalent.domains"}}' | sort | uniq | grep -v '^$'
