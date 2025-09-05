FROM python:3.10-slim-bullseye
MAINTAINER Hibou Corp. <hello@hibou.io>

ENV NODE_MAJOR=20

COPY --chown=104 requirements.txt requirements-hibou.txt /opt/odoo/odoo/

RUN set -x; \
    # Add Odoo User
    useradd -m -d /var/lib/odoo -s /bin/false -u 104 -g 33 odoo \
    && apt-get update \
    && apt-get install -y curl ca-certificates gnupg \
    # setup Node sources \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    # downgrade setuptools to support 2to3 (mainly because of vatnumber and suds-jurko) \
    && pip install setuptools\<58.0.0 \
    # installing this way works but from requirements.txt it doesn't
    && pip install suds-jurko \
    && apt-get install -y --no-install-recommends \
        zip \
        vim \
        #  for openupgrade and Odoo upgrade script
        git \
        openssh-client \
        rsync \
        #  for apt-key
        gnupg \
        #  for pip install \
        gcc g++ \
        libcurl4-openssl-dev libsasl2-dev libldap2-dev libssl-dev libyaml-dev \
        #  pillow
        libjpeg-dev zlib1g-dev \
        #  Hibou Athene
        libsecret-1-0 \
        nodejs \
    && node --version \
    && npm install yarn --global --force \
    #  install postgresql-client from postgres itself to support newer server versions
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    #  install Python Requirements
    && pip3 install -r /opt/odoo/odoo/requirements.txt \
    && pip3 install -r /opt/odoo/odoo/requirements-hibou.txt \
    && pip3 install git+https://github.com/OCA/openupgradelib.git \
    #  install wkhtmltox
    && cd /tmp \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && dpkg --force-depends -i wkhtmltox.deb \
    && rm -rf wkhtmltox.deb \
    # Clean Up
    && rm -rf /root/.cache \
    && apt --fix-broken -y install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    ;

COPY --from=registry.gitlab.com/hibou-io/athene:node20--python /opt/athene /opt/athene

USER 0
COPY --chown=104 . /opt/odoo/odoo

RUN set -x; \
    cd /opt/odoo/odoo \
    && python setup.py install \
    && mv /opt/odoo/odoo/entrypoint.sh /entrypoint.sh \
    && mv /opt/odoo/odoo/wait-for-psql.py /usr/local/bin/wait-for-psql.py \
    && chmod a+x /usr/local/bin/wait-for-psql.py \
    && mkdir -p /etc/odoo/ \
    && chown -R odoo /etc/odoo \
    && cp /opt/odoo/odoo/debian/odoo.conf /etc/odoo/odoo.conf \
    ;

VOLUME ["/var/lib/odoo"]
EXPOSE 8069 8072 3000
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/opt/athene/plugins
ENV USE_LOCAL_GIT true
ENV ODOO_RC /etc/odoo/odoo.conf
USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

