FROM ubuntu:20.04
RUN apt-get update && apt-get install -y pgpool2 && apt-get install -y postgresql-client && apt-get install -y netcat

COPY ./failover.sh /failover.sh
RUN chmod +x /failover.sh

COPY ./wait-for-db.sh /wait-for-db.sh
RUN chmod +x /wait-for-db.sh

RUN mkdir /tmp/trigger_file

ENTRYPOINT ["/wait-for-db.sh"]
CMD ["pgpool", "-n"]