# VERSION 1.8.1
# AUTHOR: Darren Haken
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/darrenhaken/docker-airflow

FROM python:3
MAINTAINER darrenhaken
LABEL com.shinko.version="0.0.1-beta"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# airflow needs a home to install into, ~/airflow is the default,
ENV AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_USER=airflow

WORKDIR /usr/src/app

RUN apt-get update \
  # Install deb packages
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    locales \
    netcat \
    curl \
    libpq-dev \
    libkrb5-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    build-essential \
  # Set locale
  && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
  # Add airflow user
  && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
  # Clean up
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure locales

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# Install dependencies
COPY requirements.txt ./
RUN pip install -r requirements.txt

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
