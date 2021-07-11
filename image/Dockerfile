FROM quay.io/hwdsl2/ipsec-vpn-server

COPY module /opt/module
RUN chmod 755 /opt/module/bin/*.sh

ENV PATH="/opt/module/bin:$PATH"

ENTRYPOINT ["run.sh"]
HEALTHCHECK --start-period=30s --interval=60s --timeout=5s --retries=3 \
    CMD healthcheck.sh || exit 1

