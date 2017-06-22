# VERSION 1.8.1
# AUTHOR: Darren Haken
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/darrenhaken/docker-airflow

FROM python:3
MAINTAINER darrenhaken
LABEL com.shinko.version="0.0.1-beta"

# airflow needs a home to install into, ~/airflow is the default,
ENV AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_USER=airflow

ARG AIRFLOW_COMMAND

# Add airflow user
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow

WORKDIR /usr/src/app

# Install dependencies
COPY requirements.txt ./
RUN pip install -r requirements.txt

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    net-tools \
    netcat \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY script/entrypoint.sh ${AIRFLOW_HOME}/entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

# Copy startup script
RUN chown -R ${AIRFLOW_USER}: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER ${AIRFLOW_USER}
WORKDIR $AIRFLOW_HOME

# This is used to wait for
ENTRYPOINT ["./entrypoint.sh"]

# This is the default command and it overridden in the docker-compose.yml
CMD ["webserver"]
