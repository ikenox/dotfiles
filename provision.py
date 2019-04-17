#!/usr/bin/env python3
import os
import subprocess
from abc import abstractmethod, ABCMeta
from typing import List


def main():
    tasks: List['Task'] = []


    mas_packages = [
        409183694,  # keynote
        409203825,  # Numbers
        409201541,  # Pages
        539883307,  # LINE
        409183694,  # Keynote
        485812721,  # TweetDeck
        668208984,  # GIPHY CAPTURE
        405399194,  # Kindle
    ]
    tasks.extend([MasTask(app_id) for app_id in mas_packages])

    Provisioner(
        BrewTask.list(

        ),
        BrewCaskTask.list()

        [BrewTask(p) for p in [
            'peco',
            'fzf',
        ]] +

        [BrewCaskTask(p) for p in [
            'slack',
            'karabiner-elements',
            'alfred',
            'iterm2',
            'caffeine',
            'google-japanese-ime',
        ]] +


    ).provision()


class Provisioner:
    def __init__(self, tasks: List['Task']):
        self.tasks = tasks

    def provision(self):
        for task in self.tasks:
            task.provision_with_dependencies()


class Task(metaclass=ABCMeta):
    @abstractmethod
    def is_provisioned(self) -> bool:
        pass

    @abstractmethod
    def provision(self) -> None:
        pass

    @abstractmethod
    def dependencies(self) -> List['Task']:
        pass

    def to_string(self) -> str:
        return str(self.__class__.__name__) + str(self.__dict__)

    def provision_with_dependencies(self, level: int = 0) -> None:
        print(("    " * level) + bold("TASK"), self.to_string(), "->", end=' ')

        if self.is_provisioned():
            print(green("already provisioned"))
            return

        print(red("not provisioned"))
        for task in self.dependencies():
            task.provision_with_dependencies(level=level + 1)
        self.provision()

red = lambda text: '\033[1;31m' + text + '\033[0m'
green = lambda text: '\033[1;32m' + text + '\033[0m'
grey = lambda text: '\033[0;32m' + text + '\033[0m'
bold = lambda text: '\033[1;34m' + text + '\033[0m'

class RootTask(Task):
    def dependencies(self) -> List['Task']:
        return []


class InstallHomeBrewTask(RootTask):

    def is_provisioned(self) -> bool:
        return is_command_exists('brew')

    def provision(self) -> None:
        cmd_exec(['/usr/bin/ruby', '-e',
                  '"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'])


class InstallHomeBrewCaskTask(Task):

    def is_provisioned(self) -> bool:
        return not cmd_has_error(['brew', 'cask'])

    def provision(self) -> None:
        cmd_exec(['brew', 'tap', 'caskroom/cask'])

    def dependencies(self) -> List['Task']:
        return [InstallHomeBrewTask()]


class MasTask(Task):

    def __init__(self, app_id: int):
        self.app_id: int = app_id

    def is_provisioned(self) -> bool:
        out = subprocess.check_output("mas list | grep '^{} '".format(self.app_id), shell=True)
        return len(out) > 0

    def provision(self) -> None:
        cmd_exec(['mas', 'install', str(self.app_id)])

    def dependencies(self) -> List['Task']:
        return [BrewTask('mas')]


class BrewTask(Task):
    PACKAGE_BASE_DIR = "/usr/local/Cellar"

    def __init__(self, package: str, install_options: List[str] = None):
        self.package: str = package
        self.install_options: List[str] = install_options or []

    def is_provisioned(self) -> bool:
        # FIXME difference of install_option is not detected
        package_path = os.path.join(__class__.PACKAGE_BASE_DIR, self.package)
        return not cmd_has_error(['ls', package_path])

    def provision(self) -> None:
        cmd_exec(['brew', 'install', self.package] + self.install_options)

    def dependencies(self) -> List['Task']:
        return [InstallHomeBrewTask()]

    @classmethod
    def list(cls, packages:List[Union[str,dict]]):



class BrewCaskTask(Task):
    PACKAGE_BASE_DIR = "/usr/local/Caskroom"

    def __init__(self, package: str, install_options: List[str] = None):
        self.package: str = package
        self.install_options: List[str] = install_options or []

    def is_provisioned(self) -> bool:
        # FIXME difference of install_option is not detected
        package_path = os.path.join(__class__.PACKAGE_BASE_DIR, self.package)
        return not cmd_has_error(['ls', package_path])

    def provision(self) -> None:
        cmd_exec(['brew', 'install', self.package] + self.install_options)

    def dependencies(self) -> List['Task']:
        return [InstallHomeBrewCaskTask()]


def is_command_exists(command: str) -> bool:
    return not cmd_has_error(['which', command])


def cmd_has_error(args: List[str]) -> bool:
    result = subprocess.run(args=args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return result.returncode != 0


def cmd_exec(args: List[str]) -> subprocess.CompletedProcess:
    return subprocess.run(args=args, check=True)


if __name__ == '__main__':
    main()
