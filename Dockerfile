FROM python:3.12


ENV VIRTUAL_ENV /env
# Set default server root
ENV DEVPI_SERVER_ROOT=/devpi

ADD ./code /code
WORKDIR /code
RUN /code/build.sh

# create a virtual env in $VIRTUAL_ENV and ensure it respects pip version
RUN python3 -m venv $VIRTUAL_ENV \
    && $VIRTUAL_ENV/bin/pip install --upgrade pip \
    && $VIRTUAL_ENV/bin/pip install --upgrade setuptools

# Install devpi and dependencies
RUN $VIRTUAL_ENV/bin/pip install -r /code/devpi-requirements.txt


# Add entrypoint
COPY devpi-client /usr/local/bin/
COPY entrypoint.sh /
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
EXPOSE 3141
