FROM debian:stretch

ENV SWAN_VER 3.29
ENV L2TP_VER 1.3.12

WORKDIR /opt/module

RUN apt-get -yqq update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -yqq --no-install-recommends install \
         wget dnsutils openssl ca-certificates kmod \
         iproute gawk grep sed net-tools iptables \
         bsdmainutils libcurl3-nss \
         libnss3-tools libevent-dev libcap-ng0 xl2tpd \
         libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
         libcap-ng-dev libcap-ng-utils libselinux1-dev \
         libcurl4-nss-dev libpcap0.8-dev \
         flex bison gcc make \
    && wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://github.com/libreswan/libreswan/archive/v${SWAN_VER}.tar.gz" \
    || wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://download.libreswan.org/libreswan-${SWAN_VER}.tar.gz" \
    && tar xzf libreswan.tar.gz \
    && rm -f libreswan.tar.gz \
    && cd "libreswan-${SWAN_VER}" \
    && printf 'WERROR_CFLAGS =\nUSE_DNSSEC = false\nUSE_DH31 = false\n' > Makefile.inc.local \
    && printf 'USE_NSS_AVA_COPY = true\nUSE_NSS_IPSEC_PROFILE = false\n' >> Makefile.inc.local \
    && printf 'USE_GLIBC_KERN_FLIP_HEADERS = true\nUSE_SYSTEMD_WATCHDOG = false\n' >> Makefile.inc.local \
    && make -s base \
    && make -s install-base \
    && cd /opt/module \
    && rm -rf "/opt/module/libreswan-${SWAN_VER}" \
    && wget -t 3 -T 30 -nv -O xl2tpd.tar.gz "https://github.com/xelerance/xl2tpd/archive/v${L2TP_VER}.tar.gz" \
    || wget -t 3 -T 30 -nv -O xl2tpd.tar.gz "https://debian.osuosl.org/debian/pool/main/x/xl2tpd/xl2tpd_${L2TP_VER}.orig.tar.gz" \
    && tar xzf xl2tpd.tar.gz \
    && rm -f xl2tpd.tar.gz \
    && cd "xl2tpd-${L2TP_VER}" \
    && make -s \
    && PREFIX=/usr make -s install \
    && cd /opt/module \
    && rm -rf "/opt/module/xl2tpd-${L2TP_VER}" \
    && apt-get -yqq remove \
         libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
         libcap-ng-dev libcap-ng-utils libselinux1-dev \
         libcurl4-nss-dev libpcap0.8-dev flex bison gcc make \
         perl-modules perl \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

COPY module /opt/module
RUN chmod 755 /opt/module/bin/run.sh

EXPOSE 500/udp 4500/udp

#
# Default skwr config
#
RUN groupadd -g 9999 skwr \
 && useradd -r -u 9999 -g skwr skwr
ENV PATH="/opt/module/bin:$PATH"
ENTRYPOINT ["run.sh"]
HEALTHCHECK --start-period=30s --interval=60s --timeout=5s --retries=3 \
    CMD healthcheck.sh || exit 1

RUN apt-get -yqq update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get -y --no-install-recommends install sudo \
 && apt-get -y clean \
 && echo 'Defaults  env_keep += "VPN_IPSEC_PSK"' > /etc/sudoers.d/skwr \
 && echo 'Defaults  env_keep += "VPN_USER"' >> /etc/sudoers.d/skwr \
 && echo 'Defaults  env_keep += "VPN_PASSWORD"' >> /etc/sudoers.d/skwr \
 && echo 'skwr    ALL=(root) NOPASSWD: /opt/module/bin/run.sh' >> /etc/sudoers.d/skwr

USER skwr

