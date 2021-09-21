import os, sys

PRIORITY = ['rosenvladimirov']
IGNORE = ['.git', 'setup', '.gitignore', '.idea', 'prodax', 'fleet_extend']
ADDONS = []


def check_dir(dir_addons, addons):
    links = []
    dir_list = os.listdir(dir_addons)
    dir_list.sort(key=lambda t: t in set(PRIORITY), reverse=True)
    dir_list = filter(lambda x: x in addons, dir_list)
    for file in dir_list:
        if os.path.isdir(dir_addons + '/' + file) and not (file in set(IGNORE)) and not os.path.islink(
                dir_addons + '/' + file):
            if os.path.exists(dir_addons + '/' + file + '/__manifest__.py'):
                links.append((dir_addons, file))
            else:
                check_dir(dir_addons + '/' + file, addons)
    return links


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('==============HELP=================')
        print('first argument: path for search')
        print('second argument: path for links')
        print('tri argument is config file')
        exit(0)
    if not os.path.isdir(sys.argv[1]) or not os.path.isdir(sys.argv[2]):
        print('Error: First and second param have to be folder')

    filename = 'addons.conf'
    with open(filename) as file:
        fl = file.readlines()
        lines = [line.rstrip() for line in fl]
    if not lines:
        lines = ADDONS
    for link in check_dir(sys.argv[1], lines):
        try:
            os.symlink('/'.join(link), sys.argv[2] + '/' + link[1])
        except FileExistsError:
            print('Duplicate: {}'.format('/'.join(link)))
