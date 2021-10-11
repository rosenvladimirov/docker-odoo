#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo11'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo11'}}}
# set for scanner for symlinks
: ${PROFILE:=${ODOO_PROFILE:='ready_full.conf'}}
: ${ADDONS:=${ODOO_ADDONS:='/opt/odoo-addons/11.0'}}
: ${ODOO_CFG_FOLDER:=${ODOO_RC_FOLDER:='/etc/odoo'}}
# set variables for odoo config file
: ${DB_NAME:=${DB_ENV_NAME:='odoodb'}}
: ${ADMIN_PASSWD:=${ODOO_ENV_ADMIN_PASSWD:='admin-odoo11'}}
: ${LOGGER:=${ODOO_ENV_LOG_HANDLER:=':INFO'}}
: ${CONFIG_TARGET:=${ODOO_RC:='/etc/odoo/odoo.conf'}}
: ${CONFIG_TEMPLATE:=${ODOO_RC:='/opt/odoo-templates/11.0'}}

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
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

#Customise used modules
python3 /usr/local/bin/make_symb_links.py /opt/odoo-11.0 $ADDONS $ODOO_PROFILE $ODOO_CFG_FOLDER

# Create configuration file from the template
if [ -e $CONFIG_TEMPLATE/openerp.cfg.tmpl ]; then
  dockerize -template $CONFIG_TEMPLATE/openerp.cfg.tmpl:$CONFIG_TARGET
fi
if [ -e $CONFIG_TEMPLATE/odoo.cfg.tmpl ]; then
  dockerize -template $CONFIG_TEMPLATE/odoo.cfg.tmpl:$CONFIG_TARGET
fi

if [ ! -f $CONFIG_TARGET ]; then
  echo "Error: one of /templates/openerp.cfg.tmpl, /templates/odoo.cfg.tmpl, /etc/odoo/odoo.conf is required"
  exit 1
fi

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
