import sys

import odoorpc


def do_odoo(host, port, database=False, superadmin=False, user='admin', password='nimda', lang='bg_BG',
            country_code='BG'):
    odoo = odoorpc.ODOO(host, port=port)

    # Check available databases
    databases = odoo.db.list()
    if database in databases:
        try:
            odoo.login(database, user, password)
        except:
            exit(1)
        exit(0)
    if database:
        odoo.db._odoo.json(
            '/jsonrpc',
            {
                'service': 'db',
                'method': 'create_database',
                'args': [superadmin, database, False, lang, password, user, country_code],
            },
        )


if __name__ == '__main__':
    if len(sys.argv) != 9:
        print('==============HELP=================')
        print(sys.argv)
        print('create_database.py host port database user password lang country_code')
        exit(0)
    do_odoo(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7], sys.argv[8])
