FROM python:3.6.6-slim-jessie
MAINTAINER Hibou Corp. <hello@hibou.io>

COPY . /opt/odoo/odoo

RUN set -x; \
    useradd -m -d /var/lib/odoo -s /bin/false -u 104 -g 33 odoo \
    && chown -R odoo /opt/odoo \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        #  for tar \
        xz-utils \
        #  for pip install \
        gcc \
        libsasl2-dev libldap2-dev libssl-dev \
    #  install postgresql-client from postgres itself to support newer server versions
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    #  install wkhtmltox
    && cd /tmp \
    && curl -o wkhtmltox.tar.xz -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
    && tar xvf wkhtmltox.tar.xz \
    && cp wkhtmltox/lib/* /usr/local/lib/ \
    && cp wkhtmltox/bin/* /usr/local/bin/ \
    && cp -r wkhtmltox/share/man/man1 /usr/local/share/man/ \
    && rm -rf wkhtmltox \
    && rm -rf /var/lib/apt/lists/* \
    && cd /opt/odoo/odoo \
    && python setup.py install \
    && mv /opt/odoo/odoo/entrypoint.sh /entrypoint.sh \
    && mkdir -p /etc/odoo/ \
    && cp /opt/odoo/odoo/debian/odoo.conf /etc/odoo/odoo.conf \
    && chown -R odoo /etc/odoo \
    ;

VOLUME ["/var/lib/odoo"]
EXPOSE 8069 8072
ENV ODOO_RC /etc/odoo/odoo.conf
USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

