import os
import json
import random
import yaml
import shutil
import subprocess
import fcntl

class JsonFile:
    def __init__(self, path):
        self.path = path
        self.data = self._read()

    def write(self):
        self._write(self.data)

    def _read(self):
        try:
            return json.load(open(self.path))
        except IOError:
            return {}

    def _write(self, data):
        tmp = '%s.tmp.%d' % (self.path, random.randrange(1000))
        with open(tmp, 'w') as f:
            json.dump(data, f)
        os.rename(tmp, self.path)

class System:
    def __init__(self, app, name):
        self.app = app
        self.name = name
        self.json = JsonFile(os.path.join(app.path, name + '.info.json'))
        self.invalid = False
        self.dir = os.path.join(app.path, name)
        self.config = app.config[name]
        self.extended_by = []

        self.fs_path = os.path.join(self.app.path, name, 'fs')
        self.mountpoint = os.path.join(self.app.path, name, 'mnt')

        if not os.path.exists(self.dir):
            os.mkdir(self.dir)

        if not self.json.data:
            self.json.data = {}

    def setup(self):
        if self.config.get('extends'):
            self.extends = self.app.systems[self.config['extends']]
            self.extends.extended_by.append(self)
        else:
            self.extends = None

        self.json.data['valid'] = self.json.data.get('valid', False)
        if self.json.data.get('fs_extends') != self.config.get('extends'):
            self.json.data['valid'] = False

    def up(self):
        if not self.json.data.get('valid'):
            self.perform_install_action()
        else:
            self.mount()

    def down(self):
        self.mark_invalid()

    def perform_install_action(self):
        self.clear_fs()
        self.mount()
        self.mark_invalid()

        if 'debootstrap' in self.config:
            self.perform_debootstrap()
        elif 'copy-dir' in self.config:
            self.perform_copy_dir()
        elif 'apt-get' in self.config:
            self.perform_apt_get()

        self.json.data['valid'] = True
        self.json.write()

    def perform_debootstrap(self):
        suite = self.config['debootstrap']
        self.json.data['fs_extends'] = None
        self.json.write()
        self.clear_fs()
        print 'Debootstraping %s...' % self.name
        subprocess.check_call(['debootstrap', suite, self.fs_path, 'http://ftp.task.gda.pl/debian'])
        self.apt_get(['--force-yes', 'debian-archive-keyring'])
        subprocess.check_call(['chroot', self.mountpoint, 'apt-get', 'update'])

    def perform_apt_get(self):
        pkgs = self.config['apt-get'].split()
        self.apt_get(pkgs)

    def apt_get(self, opt):
        subprocess.check_call(['chroot', self.mountpoint, 'apt-get', 'install', '-y'] + opt)
        subprocess.check_call(['chroot', self.mountpoint, 'apt-get', 'clean'])

    def clear_fs(self):
        self.umount()
        for sys in self.extended_by:
            sys.mark_invalid()
        self.mark_invalid()

        if os.path.exists(self.fs_path):
            shutil.rmtree(self.fs_path)
        os.mkdir(self.fs_path)

    def mount(self):
        if self.extends:
            self.extends.up()
            self.setup_union()
        else:
            self.mountpoint = self.fs_path

    def umount(self):
        for sys in self.extended_by:
            sys.umount()
        if ismount(self.mountpoint):
            subprocess.check_call(['umount', '-l', '-f', self.mountpoint])

    def mark_invalid(self):
        self.json.data['valid'] = False
        self.json.write()

    def setup_union(self):
        if not os.path.exists(self.fs_path):
            os.mkdir(self.fs_path)
        if ismount(self.mountpoint):
            # check options maybe?
            subprocess.check_call(['umount', '-l', '-f', self.mountpoint])
        if not os.path.exists(self.mountpoint):
            os.mkdir(self.mountpoint)
        xino_path = os.path.join(self.app.path, self.name + '.xino')
        subprocess.check_call(['mount', '-t', 'aufs', 'none', '-o', 'br=%s:%s=ro,noxino' % (
                               os.path.abspath(self.fs_path), os.path.abspath(self.extends.mountpoint)),
                               self.mountpoint])
        #subprocess.check_call(['mount', '-t', 'unionfs', 'none', '-o', 'dirs=%s=rw:%s=ro' % (
        #                       os.path.abspath(self.fs_path), os.path.abspath(self.extends.mountpoint)),
        #                       self.mountpoint])
        self.json.data['fs_extends'] = self.extends.name
        self.json.write()

def ismount(path):
    if os.path.ismount(path):
        return True
    try:
        os.listdir(path)
    except OSError, err:
        if err.errno == 116: # stale file handle
            return True
    return False


class FileLock(object):
    ' exclusive by default '
    def __init__(self, path, shared=False):
        self.path = path
        self.shared = shared
        self.fd = open(self.path, 'w+')

    def __enter__(self):
        fcntl.lockf(self.fd, fcntl.LOCK_SH if self.shared else fcntl.LOCK_EX)

    def __exit__(self, *args):
        fcntl.lockf(self.fd, fcntl.LOCK_UN)

class App:
    def __init__(self, path):
        self.path = path
        self.config = yaml.load(open(os.path.join(os.path.dirname(__file__), "systems.yaml")))
        self.systems = {}
        self.lock = FileLock(os.path.join(path, '_lock'))

    def setup(self):
        for name in self.config.keys():
            self.systems[name] = System(self, name)
        for name in self.config.keys():
            self.systems[name].setup()
