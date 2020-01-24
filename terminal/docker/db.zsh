## Databases
alias postgres='docker run --name postgres -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 postgres:alpine'
alias pgsql='docker run --rm -it -e PGPASSWORD=mysecretpassword --link postgres:postgres postgres:alpine psql -h postgres -U postgres'

alias mysqld='docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql'
function mysql() {
  docker run --rm -it --link mysql:mysql mysql sh -c \
    'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
}

alias redis='docker run --name redis -d -p 6379:6379 redis:alpine'
alias redis-cli='docker run -it --link redis:redis --rm redis:alpine redis-cli -h redis -p 6379'

alias cassandra='docker run --name cassandra -d -p 9042:9042 cassandra'
function cqlsh() {
  docker run -it --link cassandra:cassandra --rm cassandra sh -c 'exec cqlsh "$CASSANDRA_PORT_9042_TCP_ADDR"'
}

alias mongod='docker run --name mongo --rm -p 27017:27017 mongo'
function mongo() {
  docker run -it --link mongo:mongo --rm mongo sh -c \
    'exec mongo "$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT/test"'
}

alias mssql="docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@55w0rd' -p 1433:1433 --name mssql microsoft/mssql-server-linux"
alias sql-cli='docker run -it --rm --link mssql:mssql --entrypoint /usr/local/bin/mssql shellmaster/sql-cli -s mssql -u SA -p P@55w0rd'
