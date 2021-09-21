import os, sys

priority = ['rosenvladimirov']
ignore = ['.git', 'setup', '.gitignore', 'prodax', 'fleet_extend']
links = []

def symbl_link(source, destination, relative=True):
    os.symlink(source, destination)

def check_dir(dir):
    dirlist = os.listdir(dir)
    dirlist.sort(key=lambda t:t in set(priority), reverse=True)
    for file in dirlist:
        if os.path.isdir(dir+'/'+file) and not(file in set(ignore)) and not os.path.islink(dir+'/'+file):
            if os.path.exists(dir+'/'+file+'/__manifest__.py'):
                links.append((dir, file))
            else:
                check_dir(dir+'/'+file)

if (len(sys.argv) != 3):
    print('==============HELP=================')
    print('first param: path for search')
    print('second param: path for links')
    exit(0)
if not os.path.isdir(sys.argv[1]) or not os.path.isdir(sys.argv[2]):
    print('Error: First and second param have to be folder')

check_dir(sys.argv[1])

for link in links:
    try:
        os.symlink('/'.join(link), sys.argv[2]+'/'+link[1])
        print('Crete link: {}'.format(sys.argv[2]+'/'.join(link[1])))
    except FileExistsError:
        print('Dublicate: {}'.format('/'.join(link)))
