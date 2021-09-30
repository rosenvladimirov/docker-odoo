import os, sys
import ast

PRIORITY = ['rosenvladimirov']
IGNORE = ['.git', 'setup', '.gitignore', '.idea', 'prodax', 'fleet_extend']
ADDONS = []


def check_dir(dir_addons, links=None, depends=None, main=None):
    if depends is None:
        depends = set()
    if links is None:
        links = []
    if main is None:
        main = []
    dir_list = os.listdir(dir_addons)
    for file in dir_list:
        check_file_directory = os.path.join(dir_addons, file)
        if os.path.isdir(check_file_directory) and not (file in set(IGNORE)) and not os.path.islink(check_file_directory):
            manifest_path = os.path.join(check_file_directory, '__manifest__.py')
            if os.path.exists(manifest_path):
                print(check_file_directory)
                links.append((dir_addons, file))
                with open(manifest_path) as manifest:
                    data = ast.literal_eval(manifest.read())
                if data.get('depends'):
                    for line in data['depends']:
                        if line not in main:
                            depends.update([line])
            else:
                links, depends = check_dir(check_file_directory, links, depends, main)
    return links, depends


if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('==============HELP=================')
        print('first argument: path for search')
        print('second argument: path for links')
        print('tri argument is config file')
        exit(0)
    if not os.path.isdir(sys.argv[1]) or not os.path.isdir(sys.argv[2]):
        print('Error: First and second param have to be folder')

    filename_add = 'addons.conf'
    filename_main = 'main-addons.conf'
    with open(os.path.join(sys.argv[2], filename_add)) as file:
        fl = file.readlines()
        addons = set([line.rstrip() for line in fl])
    addons = list(addons)
    if not addons:
        lines = ADDONS
    with open(os.path.join(sys.argv[2], filename_main)) as file:
        fl = file.readlines()
        main_addons = set([line.rstrip() for line in fl])
    main_addons = list(main_addons)
    links, dependencies = check_dir(sys.argv[1], addons)
    addons += list(dependencies)
    for link in links.sort(key=lambda t: t[1] in set(PRIORITY), reverse=True):
        source = os.path.join(link[0], link[1])
        module = source.split(os.path.split(source)[-1])
        if module in main_addons:
            continue
        if module not in addons:
            continue
        target = os.path.join(sys.argv[2], link[1])
        try:
            os.symlink(source, target)
        except FileExistsError:
            print('Duplicate: {}'.format('/'.join(link)))
