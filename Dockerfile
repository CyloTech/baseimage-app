FROM phusion/baseimage:master

ENV HOME=/home/appbox \
    DEBIAN_FRONTEND=noninteractive \
    MYSQL_ROOT_PASSWORD=mysqlr00t \
    APEX_CALLBACK=false \
    INSTALL_MYSQL=false \
    INSTALL_NGINXPHP=false

RUN apt update
RUN apt install -y wget \
                   git

RUN adduser --system --disabled-password --home ${HOME} --shell /sbin/nologin --group --uid 1000 appbox

ADD /scripts /scripts
RUN chmod -R +x /scripts

RUN mkdir -p /etc/my_init.d
RUN mv /scripts/20_lemp.sh /etc/my_init.d/20_lemp.sh
RUN chmod -R +x /etc/my_init.d/20_lemp.sh

ADD /sources /sources
EXPOSE 80 3306

RUN groupmod -g 9999 nogroup && \
    usermod -g 9999 nobody && \
    usermod -u 9999 nobody && \
    usermod -g 9999 sync && \
    usermod -g 9999 _apt

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]