#!/usr/bin/env bash

docker-compose up -d postgres
docker-compose run --rm --entrypoint="airflow initdb" webserver
docker-compose up -d
