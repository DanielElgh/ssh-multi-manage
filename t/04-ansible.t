#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Test::More;

use File::Temp qw(tempfile);

use SSHMultiManage::Ansible qw(ansible_to_ssh ssh_to_ansible);

sub capture_stdout(&) {
    my ($code) = @_;
    my $output = '';
    open my $out, '>', \$output or die "Can't open scalar for stdout: $!";
    local *STDOUT = $out;
    $code->();
    return $output;
}

sub write_temp {
    my ($text) = @_;
    my ($fh, $tmpfile) = tempfile(UNLINK => 1);
    print $fh $text;
    close $fh;
    return $tmpfile;
}

subtest 'ansible_to_ssh basic conversion' => sub {
    my $inv = write_temp(<<'INV');
[webservers]
web01 ansible_host=10.0.0.1 ansible_user=deploy ansible_port=22
web02 ansible_host=10.0.0.2 ansible_user=deploy ansible_port=2222
INV

    my $output = capture_stdout { ansible_to_ssh($inv) };
    like($output, qr/host web01/i, 'web01 emitted');
    like($output, qr/hostname 10\.0\.0\.1/i, 'hostname for web01');
    like($output, qr/host web02/i, 'web02 emitted');
    like($output, qr/port 2222/i, 'port for web02');
    like($output, qr/#tags\s+webservers/i, 'tags include group name');
};

subtest 'ansible_to_ssh ungrouped hosts omit tags' => sub {
    my $inv = write_temp(<<'INV');
standalone ansible_host=192.168.1.1 ansible_user=root ansible_port=22
INV

    my $output = capture_stdout { ansible_to_ssh($inv) };
    like($output, qr/host standalone/i, 'host emitted');
    unlike($output, qr/#tags\s+unassigned/, 'unassigned tag not printed');
};

subtest 'ssh_to_ansible ungrouped hosts' => sub {
    my $hosts = {
        lonely => { hostname => 'lonely.example', user => 'root', port => 22 },
    };

    my $output = capture_stdout { ssh_to_ansible($hosts) };
    like($output, qr/^lonely\s+ansible_host=lonely\.example/m, 'ungrouped host present');
};

subtest 'ssh_to_ansible multiple groups' => sub {
    my $hosts = {
        db01 => { hostname => 'db01.example', user => 'dba', port => 5432, tags => 'prod db' },
    };

    my $output = capture_stdout { ssh_to_ansible($hosts) };
    like($output, qr/^\[prod\]$/m, 'prod group');
    like($output, qr/^\[db\]$/m,   'db group');
};

subtest 'ssh_to_ansible handles no ungrouped hosts' => sub {
    my $hosts = {
        app01 => { hostname => 'app01.example', user => 'root', port => 22, tags => 'prod' },
        app02 => { hostname => 'app02.example', user => 'root', port => 22, tags => 'prod' },
    };

    my $output = capture_stdout {
        ssh_to_ansible($hosts);
    };

    like($output, qr/^\[prod\]$/m, 'prints prod group');
    unlike($output, qr/^\[\]$/m, 'does not create empty group');
};

subtest 'ssh_to_ansible ignores empty tags' => sub {
    my $hosts = {
        web01 => { hostname => 'web01.example', user => 'root', port => 22, tags => 'prod   web' },
    };

    my $output = capture_stdout {
        ssh_to_ansible($hosts);
    };

    like($output, qr/^\[prod\]$/m, 'prints prod group');
    like($output, qr/^\[web\]$/m, 'prints web group');
    unlike($output, qr/^\[\]$/m, 'does not print empty group from extra spaces');
};

done_testing();

1;
