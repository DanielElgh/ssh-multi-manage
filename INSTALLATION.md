# Installing Dependencies in Externally Managed Environments

On many systems, it is recommended to install Perl modules from your distribution’s official packages instead of CPAN.
These packages are tested, maintained, and integrated with your system’s package manager.

Below are copy-and-paste commands for installing the required dependencies using common package managers such as pacman, dnf/yum, and apt.

## Fedora:

```
sudo dnf install \
  perl-ExtUtils-MakeMaker \
  perl-Thread-Queue \
  perl-Net-OpenSSH \
  perl-Digest-SHA \
  perl-Curses-UI \
  perl-Curses \
  perl-FindBin \
  perl-Test-Harness
```

## Ubuntu:

```
sudo apt update
sudo apt install \
  libcurses-ui-perl \
  libnet-openssh-perl \
  libterm-table-perl \
  build-essential

```
