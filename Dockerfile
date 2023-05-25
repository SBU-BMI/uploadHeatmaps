FROM mongo:4.2-bionic
RUN mv /etc/apt/sources.list.d/mongodb-org.list /tmp/mongodb-org.list && \
    apt-get update && \
    apt-get install -y curl && \
    curl -o /etc/apt/keyrings/mongodb.gpg https://pgp.mongodb.com/server-4.2.pub && \
    mv /tmp/mongodb-org.list /etc/apt/sources.list.d/mongodb-org.list;
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y wget git vim build-essential checkinstall
RUN apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev
RUN cd /usr/src && wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz && tar xzf Python-3.9.9.tgz && cd Python-3.9.9 && ./configure --enable-optimizations && make altinstall
RUN \
  apt-get install -y libcurl4 openssl && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget gnupg
RUN apt-get install -y nodejs

RUN \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

# Add files.
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/.scripts /root/.scripts

COPY convert_heatmaps.js /usr/local/bin/
COPY uploadHeatmaps.sh /usr/local/bin/
COPY helpers.sh /usr/local/bin/
COPY readpass.sh /usr/local/bin/
RUN chmod 0775 /usr/local/bin/uploadHeatmaps.sh
RUN mkdir /mnt/data

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

ENTRYPOINT tail -f /dev/null

# Define default command.
CMD ["tail -f /dev/null"]
