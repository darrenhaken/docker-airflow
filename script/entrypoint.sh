#!/usr/bin/env bash

set -e

AIRFLOW_COMMAND="airflow"
AIRFLOW_ARG="$*"
TRY_LOOP=10
: ${REDIS_HOST:="redis"}
: ${REDIS_PORT:="6379"}

: ${POSTGRES_HOST:="postgres"}
: ${POSTGRES_PORT:="5432"}
: ${POSTGRES_USER:="airflow"}
: ${POSTGRES_PASSWORD:="airflow"}
: ${POSTGRES_DB:="airflow"}

function waitForRedis {
    echo "INFO - Beginning to wait for Redis"
    if [ $AIRFLOW_ARG = "webserver" ] || [ $AIRFLOW_ARG = "worker" ] || [ $AIRFLOW_ARG = "scheduler" ] || [ $AIRFLOW_ARG = "flower" ] ; then
        count=0
        while ! nc -z $REDIS_HOST $REDIS_PORT >/dev/null 2>&1 < /dev/null; do
            if [ $count -ge $TRY_LOOP ]; then
                echo "$(date) - $REDIS_HOST still not reachable, giving up"
                exit 1
            fi
            echo "$(date) - waiting for Redis... $count/$TRY_LOOP"
            sleep 5
            (( count++ ))
        done
        echo "INFO - Redis is now available"
    fi
}

function waitForPostgres {
    echo "INFO - Beginning to wait for Postgres"
    if [ $AIRFLOW_ARG = "webserver" ] || [ $AIRFLOW_ARG = "worker" ] || [ $AIRFLOW_ARG = "scheduler" ] ; then
        count=0
        while ! nc -z $POSTGRES_HOST $POSTGRES_PORT >/dev/null 2>&1 < /dev/null; do
            if [ $count -ge $TRY_LOOP ]; then
                echo "$(date) - ${POSTGRES_HOST}:${POSTGRES_PORT} still not reachable, giving up"
                exit 1
            fi
            echo "$(date) - waiting for ${POSTGRES_HOST}:${POSTGRES_PORT}... $count/$TRY_LOOP"
            sleep 5
            (( count++ ))
        done
        echo "INFO - Postgres is now available"
    fi
}

function initdbForWebServerContainer {
    if [ $AIRFLOW_ARG = "webserver" ]; then
        echo "INFO Container detected as webserver so initialising the database"
        ${AIRFLOW_COMMAND} initdb
        sleep 5
    fi
}

waitForPostgres
waitForRedis
initdbForWebServerContainer

echo "INFO Container starting as ${AIRFLOW_ARG}"
exec ${AIRFLOW_COMMAND} $AIRFLOW_ARG
