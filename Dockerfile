#
# Dockerfile for pfioh repository.
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/pfioh .
#
# In the case of a proxy (located at 192.168.13.14:3128), do:
#
#    docker build --build-arg http_proxy=http://192.168.13.14:3128 --build-arg UID=$UID -t local/pfioh .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti --entrypoint /bin/bash local/pfioh
#
# To pass an env var HOST_IP to container, do:
#
#   docker run -ti -e HOST_IP=$(ip route | grep -v docker | awk '{if(NF==11) print $9}') --entrypoint /bin/bash local/pfioh
#

FROM fnndsc/ubuntu-python3:latest
MAINTAINER fnndsc "dev@babymri.org"

# Pass a UID on build command line (see above) to set internal UID
ARG UID=1001
ENV UID=$UID

RUN apt-get update \
  && apt-get install sudo                                             \
  && useradd -u $UID -ms /bin/bash localuser                          \
  && addgroup localuser sudo                                          \
  && echo "localuser:localuser" | chpasswd                            \
  && adduser localuser sudo                                           \
  && apt-get install -y libssl-dev libcurl4-openssl-dev bsdmainutils vim net-tools inetutils-ping \
  && pip3 install --prefix /usr pfioh==1.5.5                          \
  && pip3 install pudb                                                \
  && pip3 install keystoneauth1                                       \
  && pip3 install python-swiftclient

COPY ./docker-entrypoint.py /dock/docker-entrypoint.py
RUN chmod 777 /dock                                                   \
  && chmod 777 /dock/docker-entrypoint.py                             \
  && echo "localuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENTRYPOINT ["/dock/docker-entrypoint.py"]
EXPOSE 5055

# Start as user $UID
# USER $UID