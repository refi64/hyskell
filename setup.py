try:
    # assert False
    from setuptools import setup
    from setuptools.command.install import install
    from setuptools.command.install_lib import install_lib
    kw = {'install_requires': 'hy >= 0.9.12'}
except:
    from distutils.core import setup
    from distutils.command.install import install
    from distutils.command.install_lib import install_lib
    kw = {}

# XXX: This is a hack
import os, shutil

orig_run = install_lib.run

def run(self):
    self.skip_build = True
    if not os.path.isdir(self.build_dir):
        os.makedirs(os.path.join(os.path.curdir, self.build_dir))
        shutil.copy('hyskell.hy', os.path.join(self.build_dir, 'hyskell.hy'))
    orig_run(self)

install_lib.run = run

assert install.sub_commands[0][0] == 'install_lib'
install.sub_commands[0] = (install.sub_commands[0][0], lambda *_: True)

version = '0.1'

try:
    with open('README.rst', 'r') as f:
        readme = f.read()
except:
    readme = ''

setup(name='Hyskell',
      version=version,
      description='Functional-ish stuff for Hy',
      long_description=readme,
      author='Ryan Gonzalez',
      classifiers=[
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Topic :: Software Development :: Testing'
      ],
      requires=['hy (>=0.9.12)'],
      **kw)
