#!/usr/bin/env bash
## reset_db.sh

[ $# -lt 1 ] && echo 'Usage: reset_db /path/to/dump.sql' && exit 1

declare DB_NAME='shop_3' \
        DUMP_PATH=${1:-'anon.dump'}

echo "You are going to wipe database '$DB_NAME' and reload it from the dump. Continue? (y/N)"
read -n1 answer
echo

if [[ ! "$answer" =~ [yY] ]]; then
    echo "Aborted."
    exit 2
fi

docker cp ${DUMP_PATH} shop_db:/${DUMP_PATH}

docker exec -it shop_db ls

echo "Dropping database $DB_NAME..."
docker exec -it shop_db dropdb -U postgres ${DB_NAME}

echo "Creating database $DB_NAME..."
docker exec -it shop_db createdb -U postgres ${DB_NAME}

echo "Loading data from $DUMP_PATH..."
docker exec -i shop_db psql -U postgres ${DB_NAME} < ${DUMP_PATH}

docker exec -it shop_db rm ${DUMP_PATH}
docker exec -it shop_db ls

echo "Done"




