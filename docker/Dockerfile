# ChatGPT was a great help in explaining the different lines of this complex docker file.

FROM python:3.10-slim

# Build arguments. These have default values that can be changes 
# when building the container i.e,
# docker build --build-args USER_NAME=my_name
# or via de docker-compose.yaml
ARG USER_ID
ARG USER_NAME

# Set environment variables 
ENV HOME=/home/${USER_NAME} \
    VIRTUAL_ENV=/home/${USER_NAME}/venv
ENV \
  PYTHONUNBUFFERED=1 \
  DEBIAN_FRONTEND=noninteractive \
  TZ=Europe/Warsaw \
  PATH="/usr/local/gcloud/google-cloud-sdk/bin:${HOME}/.local/bin:${VIRTUAL_ENV}/bin:${PATH}" \
  PYTHONPATH="/app:${PYTHONPATH}" \
  BUILD_POETRY_LOCK="${HOME}/poetry.lock.build"

# run commands to update the container and install some essential
# packages    
RUN apt-get -qq update \
    && apt-get -qq -y install vim gcc curl git build-essential libb64-dev software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -qq -y clean

# 1. Created a group with gid={USER_ID} and user name {USER_NAME}
# 2. Create a user with the same USER_ID (uid) as on the host, 
#    add it to {USER_NAME} group created under step 1 
# 
# REMARK: this very iportant in relation to the docker-compose.yaml where a
# bind mount is defined. It makes sure that the rights on the container match the
# rights on the host. Initially I had this incorrect result in permission error
# on the container (app directory). 
RUN addgroup --system --gid ${USER_ID} ${USER_NAME} \
    && useradd --system -m --no-log-init --home-dir ${HOME} --uid ${USER_ID} --gid ${USER_NAME} --groups ${USER_NAME} ${USER_NAME}

# recursively change the ownership of the home directory and all files in it to the new user
RUN chown -R ${USER_NAME}:${USER_NAME} ${HOME}
# recursively change ownership of the app and tmp directory (store of project files)
RUN mkdir -p /app 
RUN mkdir -p /app && chown -R ${USER_NAME}:${USER_NAME} /app /tmp

# downloads the install script and pipes to python3 to install a specific version
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.7.1

# change the user
USER ${USER_NAME}

# This copies the poetry pyproject.toml and .lock files to the directory app
# and changes the working dir to app.
# 1. If you use the Dockerfile directly to build an image the files MUST be in 
# the directory with the Dockerfile (otherwise you get an error)
COPY pyproject.toml *.lock /app/

# 2. docker-compose - TODO
WORKDIR /app

# use chatgpt to get more detailed info
# poetry is set to no create its own virtual enviroment instead it uses the venv package
# it installs the pip and setuptools, runs poetry install 
# it copies the lock file to /home/{USER}/poetry.lock (I guess needed when we change the user again)
RUN poetry config virtualenvs.create false \
    && python3.10 -m venv ${VIRTUAL_ENV} \
    && pip install --upgrade pip setuptools \
    && poetry install && cp poetry.lock ${BUILD_POETRY_LOCK} \
    && rm -rf ${HOME}/.cache/*

# change back to the root user and copy all files from /docker/scripts to the current
# directory
USER root
# Use below if the docker build is run from directory that contains the docker file
# COPY ./scripts/* /
# use below if the docker image is build using docker-compose (one directory up)
COPY ./docker/scripts/* /

# change ownership the shell scripts to the created user
# than change the permission to make the script executable by the user
RUN chown -R ${USER_NAME} /*.sh && chmod +x /*.sh

# change back to the user that was created
USER ${USER_NAME}
    
RUN git config --global user.email "sacha.van.weeren@gmail.com" \
    && git config --global user.name "longtongster"

COPY . /app/
CMD ["/startup-script.sh"]