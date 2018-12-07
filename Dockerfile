FROM python:3.7.1-slim-stretch
MAINTAINER Hibou Corp. <hello@hibou.io>

COPY --chown=104 . /opt/odoo/odoo

RUN set -x; \
    # Add Odoo User
    useradd -m -d /var/lib/odoo -s /bin/false -u 104 -g 33 odoo \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        #  for apt-key
        gnupg \
        #  for pip install \
        gcc \
        libsasl2-dev libldap2-dev libssl-dev \
    ; \
    #  install postgresql-client from postgres itself to support newer server versions
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
	; \
    #  install wkhtmltox
    cd /tmp \
    && curl -o wkhtmltox.deb -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && dpkg --force-depends -i wkhtmltox.deb \
    && rm -rf wkhtmltox.deb \
    ; \
    cd /opt/odoo/odoo \
    && python setup.py install \
    && mv /opt/odoo/odoo/entrypoint.sh /entrypoint.sh \
    && mkdir -p /etc/odoo/ \
    && cp /opt/odoo/odoo/debian/odoo.conf /etc/odoo/odoo.conf \
    # Clean Up
    && rm -rf /root/.cache \
    && apt --fix-broken -y install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    ;

VOLUME ["/var/lib/odoo"]
EXPOSE 8069 8072
ENV ODOO_RC /etc/odoo/odoo.conf
USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

