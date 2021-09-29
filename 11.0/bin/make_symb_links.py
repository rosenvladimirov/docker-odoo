import os, sys
import ast

PRIORITY = ['rosenvladimirov']
IGNORE = ['.git', 'setup', '.gitignore', '.idea', 'prodax', 'fleet_extend']
ADDONS = []


def check_dir(dir_addons, addons):
    dependencies = set()
    links = []
    dir_list = os.listdir(dir_addons)
    dir_list.sort(key=lambda t: t in set(PRIORITY), reverse=True)
    dir_list = filter(lambda x: x in addons, dir_list)
    for file in dir_list:
        check_file = os.path.join(dir_addons, file)
        if os.path.isdir(check_file) and not (file in set(IGNORE)) and not os.path.islink(check_file):
            manifest_path = os.path.join(check_file, '__manifest__.py')
            if os.path.exists(manifest_path):
                with open(manifest_path) as manifest:
                    data = ast.literal_eval(manifest.read())
                dependencies.update(data['depends'])
                links.append((dir_addons, file))
            else:
                check_dir(check_file, addons)
    return links, dependencies


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
        lines = set([line.rstrip() for line in fl])
    lines = list(lines)
    if not lines:
        lines = ADDONS
    for link, dependencies in check_dir(sys.argv[1], lines):
        try:
            os.symlink('/'.join(link), sys.argv[2] + '/' + link[1])
        except FileExistsError:
            print('Duplicate: {}'.format('/'.join(link)))
