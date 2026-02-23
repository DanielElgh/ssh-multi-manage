#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Test::More;
use File::Temp qw(tempfile);

use SSHMultiManage::Common qw(get_hosts get_hosts_enriched);

# Helper: write a temp SSH config and parse it
sub parse_config {
    my ($text) = @_;
    my ($fh, $tmpfile) = tempfile(UNLINK => 1);
    print $fh $text;
    close $fh;
    return get_hosts($tmpfile);
}

sub parse_config_enriched {
    my ($text) = @_;
    my ($fh, $tmpfile) = tempfile(UNLINK => 1);
    print $fh $text;
    close $fh;
    return get_hosts_enriched($tmpfile);
}

subtest 'basic host parsing' => sub {
    my $hosts = parse_config(<<'SSH');
Host myserver
    HostName 10.0.0.1
    User admin
    Port 2222
SSH
    ok(exists $hosts->{myserver}, 'host parsed');
    is($hosts->{myserver}{hostname}, '10.0.0.1', 'hostname');
    is($hosts->{myserver}{user}, 'admin', 'user');
    is($hosts->{myserver}{port}, '2222', 'port');
};

subtest 'defaults applied when missing' => sub {
    my $hosts = parse_config(<<'SSH');
Host bare
    HostName bare.example.com
SSH
    is($hosts->{bare}{hostname}, 'bare.example.com', 'hostname set');
    ok(defined $hosts->{bare}{user}, 'user defaulted');
    is($hosts->{bare}{port}, 22, 'port defaults to 22');
};

subtest 'hostname defaults to host alias' => sub {
    my $hosts = parse_config(<<'SSH');
Host aliasonly
    User deploy
SSH
    is($hosts->{aliasonly}{hostname}, 'aliasonly', 'hostname defaults to host alias');
};

subtest 'wildcard hosts excluded' => sub {
    my $hosts = parse_config(<<'SSH');
Host *
    ServerAliveInterval 60

Host myhost
    HostName myhost.example.com
SSH
    ok(!exists $hosts->{'*'}, 'wildcard host removed');
    ok(exists $hosts->{myhost}, 'normal host kept');
};

subtest 'tags comment parsed' => sub {
    my $hosts = parse_config(<<'SSH');
Host tagged
    HostName tagged.example.com
    # tags prod web
SSH
    is($hosts->{tagged}{tags}, 'prod web', 'tags parsed from comment');
};

subtest 'multiple hosts in file' => sub {
    my $hosts = parse_config(<<'SSH');
Host alpha
    HostName alpha.example.com
    User root

Host beta
    HostName beta.example.com
    User deploy
    Port 2222
SSH
    is(scalar keys %$hosts, 2, 'two hosts parsed');
    is($hosts->{alpha}{user}, 'root', 'alpha user');
    is($hosts->{beta}{port}, '2222', 'beta port');
};

subtest 'empty config returns empty hash' => sub {
    my $hosts = parse_config('');
    is(scalar keys %$hosts, 0, 'no hosts for empty config');
};

subtest 'comments and blank lines are skipped' => sub {
    my $hosts = parse_config(<<'SSH');
# This is a comment

Host server1
    HostName server1.example.com
    # Another comment
    User root

SSH
    is(scalar keys %$hosts, 1, 'one host parsed');
};

subtest 'multi-word Host line uses first name' => sub {
    my $hosts = parse_config(<<'SSH');
Host primary alias1 alias2
    HostName primary.example.com
SSH
    ok(exists $hosts->{primary}, 'first name kept');
    ok(!exists $hosts->{alias1}, 'alias not top-level');
};

subtest 'enriched hosts preserve base fields' => sub {
    no warnings 'redefine';
    local *SSHMultiManage::Common::_enrich_host = sub {
        my ($host) = @_;
        return {
            hostname => "${host}.example.net",
            user     => 'sshg',
            port     => '2201',
        };
    };

    my $hosts = parse_config_enriched(<<'SSH');
Host app01
    # tags prod web
SSH

    ok(exists $hosts->{app01}, 'host parsed');
    is($hosts->{app01}{hostname}, 'app01.example.net', 'enriched hostname applied');
    is($hosts->{app01}{user}, 'sshg', 'enriched user applied');
    is($hosts->{app01}{port}, '2201', 'enriched port applied');
    is($hosts->{app01}{tags}, 'prod web', 'base tags preserved');
};

done_testing();

1;
