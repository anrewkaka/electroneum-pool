FROM ubuntu:17.10

WORKDIR /opt/electroneum-pool

EXPOSE 80

ENV NAME electroneum-pool

# Update package
RUN  apt-get -qq update \
  && apt-get install -y wget \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl --silent --location https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install --yes nodejs \
  && apt-get install --yes build-essential

# Install libssl, boost
RUN apt-get install -y libssl-dev libboost-all-dev

# install redis
# Install Redis.
RUN \
  cd /tmp \
  && wget http://download.redis.io/redis-stable.tar.gz \
  && tar xvzf redis-stable.tar.gz \
  && cd redis-stable \
  && make \
  && make install \
  && cp -f src/redis-sentinel /usr/local/bin \
  && mkdir -p /etc/redis \
  && cp -f *.conf /etc/redis \
  && rm -rf /tmp/redis-stable* \
  && sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf \
  && sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf \
  && sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf \
  && sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

# Define mountable directories.
VOLUME ["/data"]

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# install electroneum pool
RUN \
  cd /opt/electroneum-pool \
  && git clone https://github.com/electroneum/electroneum-pool.git pool \
  && cd pool \
  && npm update \
  && node init.js
