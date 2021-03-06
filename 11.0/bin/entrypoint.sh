#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi
START_ENTRYPOINT_DIR=/etc/odoo/start-entrypoint.d

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:=${POSTGRES_HOST:='db'}}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=${POSTGRES_PORT:=5432}}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo11'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo11'}}}
: ${SUPER_USER:=${DB_ENV_POSTGRES_SUPERUSER:=${POSTGRES_SUPERUSER:='odoo'}}}
: ${SUPER_PASSWORD:=${DB_ENV_POSTGRES_SUPERPASSWORD:=${POSTGRES_SUPERPASSWORD:='odoo11'}}}
# set for scanner for symlinks
: ${PROFILE:=${ODOO_PROFILE:='ready_full.conf'}}
: ${ADDONS:=${ODOO_ADDONS:='/opt/odoo-addons/11.0'}}
: ${ODOO_CFG_FOLDER:=${ODOO_RC_FOLDER:='/etc/odoo'}}
# set variables for odoo config file
: ${DB_NAME:=${DB_ENV_NAME:='odoodb'}}
: ${ADMIN_PASSWD:=${ODOO_ENV_ADMIN_PASSWD:='admin-odoo11'}}
: ${LOGGER:=${ODOO_ENV_LOG_HANDLER:=':INFO'}}
: ${CONFIG_TARGET:=${ODOO_RC:='/etc/odoo/odoo.conf'}}
: ${CONFIG_TEMPLATE:=${ODOO_RC_TEMPLATE:='/etc/odoo/templates'}}


DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$SUPER_USER"
check_config "db_password" "$SUPER_PASSWORD"

# create superuser for database access
if [ ! -e ~/.pgpass ]; then
  echo "$HOST:$PORT:*:$SUPER_USER:$SUPER_PASSWORD" >> ~/.pgpass
  /bin/chmod 0600 ~/.pgpass
fi

#Customise used modules
if [ "$RUNNING_ENV" == 'prod' ] || [ "$RUNNING_ENV" == '' ]; then
  python3 /usr/local/bin/make_symb_links.py /opt/odoo-11.0 $ADDONS $PROFILE $ODOO_CFG_FOLDER
fi
if [ "$RUNNING_ENV" == 'dev' ]; then
  python3 /usr/local/bin/make_symb_links.py /opt/dev/oodoo-11.0 $ADDONS $PROFILE $ODOO_CFG_FOLDER
fi

# Create configuration file from the template
if [ -e $CONFIG_TEMPLATE/odoo.cfg.tmpl ]; then
  dockerize -template $CONFIG_TEMPLATE/odoo.cfg.tmpl:$CONFIG_TARGET
fi

if [ ! -f $CONFIG_TARGET ]; then
  echo "Error: one of /etc/odoo/templates/odoo.cfg.tmpl, /etc/odoo/odoo.conf is required"
  exit 1
fi

cat /etc/odoo/odoo.conf
case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            if [ -d "$START_ENTRYPOINT_DIR" ]; then
              run-parts --verbose "$START_ENTRYPOINT_DIR"
            fi
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        if [ -d "$START_ENTRYPOINT_DIR" ]; then
          run-parts --verbose "$START_ENTRYPOINT_DIR"
        fi
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
