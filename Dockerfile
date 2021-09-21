FROM ubuntu:18.04
MAINTAINER Rosen Vladimirov <vladimirov.rosen@gmail.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale bg_BG.UTF-8 for postgres and general locale data
ENV LANG bg_BG.UTF-8
ENV TZ=Europe/Sofia

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            openssh-client \
            build-essential \
            gcc \
            python3-dev \
            libevent-dev \
            libfreetype6-dev \
            libxml2-dev \
            libxslt1-dev \
            libsasl2-dev \
            libldap2-dev \
            libjpeg-dev \
            libpng-dev \
            zlib1g-dev \
            git \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl1.0-dev \
            node-less \
            python3-pip \
            python3-babel \
            python3-decorator \
            python3-docutils \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-slugify \
            python3-sortedcontainers \
            python3-vobject \
            python3-watchdog \
            python3-xlrd \
            xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
        && echo 'f1689a1b302ff102160f2693129f789410a1708a wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
        && GNUPGHOME="$(mktemp -d)" \
        && export GNUPGHOME \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install --no-install-recommends -y postgresql-client \
        && rm -f /etc/apt/sources.list.d/pgdg.list \
        && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Ubuntu 18.04)
RUN echo "deb http://deb.nodesource.com/node_8.x bionic main" > /etc/apt/sources.list.d/nodesource.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/nodejs.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install --no-install-recommends -y nodejs \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

# Install Odoo
ENV ODOO_VERSION 11.0
ARG ODOO_RELEASE=20201204
ARG ODOO_SHA=4878c5ec8cfcbdec10f90bd47d5ea677806d728d
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
        && apt-get update \
        && apt-get -y install --no-install-recommends ./odoo.deb \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file and precompiled deb packages
COPY ./src/python3*.deb /usr/src
COPY ./bin/entrypoint.sh /
COPY ./etc/odoo.conf /etc/odoo/
COPY ./etc/addons.conf /etc/odoo/

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons \
    && mkdir -p /opt/odoo-11.0 \
    && chown -R odoo /opt/odoo-11.0 \
    && mkdir -p /opt/odoo-addons/11.0 \
    && chown -R odoo /opt/odoo-addons/11.0 \
    && mkdir -p /root/.ssh

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY ./bin/wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY ./bin/repositories.sh /opt/odoo-11.0/repositories.sh
COPY ./bin/make_symb_links.py /usr/local/bin/make_symb_links.py
COPY ./python3/base_requirements.txt /opt/odoo-11.0
COPY ./python3/extra_requirements.txt /opt/odoo-11.0
COPY ./keys/id_rsa /root/.ssh
COPY ./keys/id_rsa.pub /root/.ssh
COPY ./keys/known_hosts /root/.ssh

#    && python3 /usr/local/bin/make_symb_links.py /opt/odoo-11.0 /opt/odoo-addons/11.0 \

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts \
    && cd /opt/odoo-11.0 \
    && ./repositories.sh \
    && dpkg -i /usr/src/python3-*.deb \
    && pip3 install -r /opt/odoo-11.0/base_requirements.txt --ignore-installed \
    && rm -f /root/.ssh/id_rsa \
    && rm -f /root/.ssh/id_rsa.pub \
    && rm -f /root/.ssh/known_hosts \
    && rm -f /usr/src/python-*.deb

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]