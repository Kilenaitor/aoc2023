FROM hhvm/hhvm:4.172.0
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install it all
RUN apt-get -qq update && \
    apt-get -qq autoclean && \
    apt-get -qq install -y \
    vim \
    software-properties-common

# Application Storage
RUN mkdir -p /var/aoc2023/
RUN chown -R www-data:www-data /var/aoc2023/

# Webserver Setup
ADD hhvm.ini /etc/hhvm/server.ini

# Copy code over
ADD . /var/aoc2023/
WORKDIR /var/aoc2023/

EXPOSE 80
CMD ["/usr/bin/hhvm", "-m", "server", "-c", "/etc/hhvm/server.ini"]
