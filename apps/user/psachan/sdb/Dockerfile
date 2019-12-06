FROM dva-registry.internal.salesforce.com/dva/sfdc_centos7_java:17

ARG OWNER=sdb
ENV BASE_DIR /home/$OWNER

ENV LANG en_US.UTF-8

RUN groupadd --system --gid 7033 sdb &&     adduser --system --gid 7033 --uid 1359 --shell /sbin/nologin sdb

RUN yum --disableplugin=fastestmirror -y install perl-Data-Dumper bzip2

RUN mkdir -p /home/sdb
WORKDIR /home/sdb
EXPOSE 1521
RUN chown 1359:7033 /home/sdb
COPY install.sh /home/sdb/install.sh
COPY postgresql.conf.dev /home/sdb/postgresql.conf.dev
RUN chmod 644 /home/sdb/postgresql.conf.dev

USER sdb
ENV PATH=$PATH:/home/sdb/pgbuild/bin

RUN chmod 777 /home/sdb
RUN mkdir -p mydir
COPY --chown=1359:7033 deploy.324.10.1.ssl.tar.bz2 ./mydir
COPY --chown=1359:7033 19252256.sdbdata.tar.bz2 ./mydir
COPY --chown=1359:7033 myinstall.sh ./mydir
COPY --chown=1359:7033 scheduler-db/src/main/resources/214/base/* ./mydir/
COPY --chown=1359:7033 scheduler-db/src/main/resources/214/function/* ./mydir/
RUN chmod -R 777 mydir

ENTRYPOINT ["/home/sdb/mydir/myinstall.sh"]
