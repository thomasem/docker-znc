# ZNC IRC Bouncer
#
# ZNC Website:  http://wiki.znc.in/ZNC
# ZNC Version:  1.6.0
#
# VERSION:      1.0

FROM ubuntu:14.04
MAINTAINER Thomas Maddox <thomas.e.maddox@gmail.com>

RUN apt-get update && \
    apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:teward/swig3.0 && \
    apt-get update

RUN apt-get install -y \
    wget \
    build-essential \
    libssl-dev \
    libperl-dev \
    pkg-config \
    swig3.0 \
    libicu-dev \
    python3-dev

RUN wget http://znc.in/releases/znc-1.6.0.tar.gz
RUN tar -xzvf znc*.*gz && cd znc*
WORKDIR /znc-1.6.0
RUN ./configure --enable-python --enable-perl && make && make install

RUN useradd --create-home -d /var/lib/znc --system --shell /sbin/nologin \
    --comment "Account to run ZNC daemon" --user-group znc

WORKDIR /var/lib/znc
VOLUME /var/lib/znc

USER znc
ENTRYPOINT ["/usr/local/bin/znc", "--datadir", "/var/lib/znc"]
CMD ["--foreground"]
