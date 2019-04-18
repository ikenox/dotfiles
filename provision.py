#!/usr/bin/env python3
import os
import subprocess
from abc import abstractmethod, ABCMeta
from typing import List


def main():
    Provisioner([

        # brew
        InstallHomeBrewTask(),
        BrewTask('peco'),
        BrewTask('fzf'),
        BrewTask('mas'),

        # brew cask
        InstallHomeBrewCaskTask(),
        BrewCaskTask('slack'),
        BrewCaskTask('karabiner-elements'),
        BrewCaskTask('alfred'),
        BrewCaskTask('iterm2'),
        BrewCaskTask('caffeine'),
        BrewCaskTask('google-japanese-ime'),

        # mas
        MasTask(409183694),  # keynote
        MasTask(409203825),  # Numbers
        MasTask(409201541),  # Pages
        MasTask(539883307),  # LINE
        MasTask(409183694),  # Keynote
        MasTask(485812721),  # TweetDeck
        MasTask(405399194),  # Kindle

        # vim

    ]).provision()


class Provisioner:
    def __init__(self, tasks: List['Task']):
        self.tasks = tasks

    def provision(self):
        for task in self.tasks:
            task.provision_if_not()


class Task(metaclass=ABCMeta):
    @abstractmethod
    def is_provisioned(self) -> bool:
        pass

    @abstractmethod
    def provision(self) -> None:
        pass

    def to_string(self) -> str:
        return str(self.__class__.__name__) + str(self.__dict__)

    def provision_if_not(self, level: int = 0) -> None:
        print(("    " * level) + bold("TASK"), self.to_string(), "->", end=' ')

        if self.is_provisioned():
            print(green("already provisioned"))
            return

        print(red("not provisioned"))
        self.provision()


red = lambda text: '\033[1;31m' + text + '\033[0m'
green = lambda text: '\033[1;32m' + text + '\033[0m'
grey = lambda text: '\033[0;32m' + text + '\033[0m'
bold = lambda text: '\033[1;34m' + text + '\033[0m'


class InstallHomeBrewTask(Task):

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


class MasTask(Task):

    def __init__(self, app_id: int):
        self.app_id: int = app_id

    def is_provisioned(self) -> bool:
        return not cmd_has_error(["mas list | grep '^{} '".format(self.app_id)])

    def provision(self) -> None:
        cmd_exec(['mas', 'install', str(self.app_id)])


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


def is_command_exists(command: str) -> bool:
    return not cmd_has_error(['which', command])


def cmd_has_error(args: List[str]) -> bool:
    result = subprocess.run(args=args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True)
    return result.returncode != 0


def cmd_exec(args: List[str]) -> subprocess.CompletedProcess:
    return subprocess.run(args=args, check=True, shell=True)


if __name__ == '__main__':
    main()
