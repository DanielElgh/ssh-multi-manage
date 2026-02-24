#!/usr/bin/env perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'SSHMultiManage',
    VERSION_FROM => 'lib/SSHMultiManage/Version.pm',
    ABSTRACT     => 'A lightweight toolkit that enhances SSH for managing multiple hosts. It checks host availability, latency, OS details, and uptime, and provides a text-based interface for quickly browsing and connecting to configured servers.',
    AUTHOR       => 'Daniel Elgh',
    LICENSE      => 'mit',

    PREREQ_PM => {
        'Carp'              => 0,
        'Curses'            => 0,
        'Curses::UI'        => 0,
        'Cwd'               => 0,
        'Digest::SHA'       => 0,
        'Exporter'          => 0,
        'File::Basename'    => 0,
        'File::Copy'        => 0,
        'File::Spec'        => 0,
        'File::Temp'        => 0,
        'FindBin'           => 0,
        'Getopt::Long'      => 0,
        'IO::Socket::IP'    => 0,
        'IPC::Open3'        => 0,
        'List::Util'        => 0,
        'Net::OpenSSH'      => 0,
        'Socket'            => 0,
        'Symbol'            => 0,
        'Term::ANSIColor'   => 0,
        'Term::Table'       => 0,
        'threads'           => 0,
        'Thread::Queue'     => 0,
        'Time::HiRes'       => 0,
        'version'           => 0,
    },

    TEST_REQUIRES => {
        'Test::More' => 0,
        'File::Spec' => 0,
        'File::Temp' => 0,
    },

    EXE_FILES    => ['bin/connect', 'bin/vihosts', 'bin/lssrv', 'bin/configdump', 'bin/hostcheck', 'bin/s2a', 'bin/a2s'],
);
