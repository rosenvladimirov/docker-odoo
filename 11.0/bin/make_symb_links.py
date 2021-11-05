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
    dir_list.sort(key=lambda t: t in set(PRIORITY), reverse=True)
    for file in dir_list:
        check_file_directory = os.path.join(dir_addons, file)

        if os.path.isdir(check_file_directory) and not (file in set(IGNORE)) and not os.path.islink(check_file_directory):
            manifest_path = os.path.join(check_file_directory, '__manifest__.py')
            if os.path.exists(manifest_path):
                # print(check_file_directory)
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


#def reverse_word(word):
#    return word[1] in PRIORITY


if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('==============HELP=================')
        print(sys.argv)
        print('first argument: path for search')
        print('second argument: path for links')
        print('tri argument is config file')
        exit(0)
    if not os.path.isdir(sys.argv[1]) or not os.path.isdir(sys.argv[2]):
        print('Error: First and second param have to be folder')

    filename_add = sys.argv[3]
    filename_main = 'main-addons.conf'
    with open(os.path.join(sys.argv[4], filename_add)) as file:
        fl = file.readlines()
        addons = set([line.rstrip() for line in fl])
    addons = list(addons)
    if not addons:
        lines = ADDONS
    with open(os.path.join(sys.argv[4], filename_main)) as file:
        fl = file.readlines()
        main_addons = set([line.rstrip() for line in fl])
    main_addons = list(main_addons)
    links, dependencies = check_dir(sys.argv[1], addons)
    addons += list(dependencies)
    extra_addons_path = '/mnt/extra-addons'
    extra_addons, dependencies = check_dir(extra_addons_path, addons)
    main_addons += extra_addons
    addons += list(dependencies)
    # print(addons)
    # links = sorted(links, key=reverse_word, reverse=True)
    for link in links:
        source = os.path.join(link[0], link[1])
        target = os.path.join(sys.argv[2], link[1])
        # print(source, target)
        # print(link[1])
        if link[1] in main_addons:
            continue
        if link[1] not in addons:
            continue
        try:
            os.symlink(source, target)
        except FileExistsError:
            print('Duplicate: {}'.format('/'.join(link)))
