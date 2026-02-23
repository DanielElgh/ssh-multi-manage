package SSHMultiManage::Common;
# SPDX-License-Identifier: MIT

use strict;
use warnings;
use Carp qw(confess cluck);
use IO::Socket::IP;
use Socket qw(getaddrinfo getnameinfo AF_UNSPEC NI_NUMERICHOST SOCK_STREAM);
use Time::HiRes qw(time);

use File::Spec;
use List::Util qw(max);

use Exporter 'import';
our @EXPORT_OK = qw(get_config_file arg_match get_hosts get_hosts_enriched get_maxlen looks_true is_x check_port resolve_hostname slurp);


sub get_config_file {
    if (defined $ENV{CONNECT_CONFIG_FILE} && length $ENV{CONNECT_CONFIG_FILE}) {
        my $env_file = $ENV{CONNECT_CONFIG_FILE};
        die "CONNECT_CONFIG_FILE path contains null bytes\n" if $env_file =~ /\0/;
        return $env_file if -e $env_file;
    }

    my @candidates = (
        File::Spec->catfile($ENV{HOME}, '.ssh','config')
    );

    for my $file (@candidates) {
        next unless defined $file && length $file;
        return $file if -e $file;
    }

    die "No configuration file found (tried CONNECT_CONFIG_FILE and ~/.ssh/config)\n";
}


# arg_match: returns true if any of the @targets are found in @$aref
# removes all matched targets from @$aref.
# Example: arg_match(\@ARGV, '--help', '-h', '-?', '/?', ...)
sub arg_match {
    my ($aref, @targets) = @_;
    my $matched = 0;

    my %is_target = map { $_ => 1 } @targets;

    @$aref = grep {
        $is_target{$_} ? ($matched = 1, 0) : 1
    } @$aref;

    return $matched;
}


sub get_hosts {
    my $file = shift // get_config_file();

    my %hosts;
    my $current;

    open my $fh, '<', $file or die "Can't open $file: $!";

    while (<$fh>) {
        chomp;
        s/^\s+|\s+$//g;          # trim leading/trailing whitespace

        # Before we skip comments, check if it's our custom "tags" field.
        if ($current && /^#\s*tags?\s+(\S.*?)\s*(?:#.*)?$/i) {
            my ($value) = ($1);
            $hosts{$current}{'tags'} = $value;
        }

        # skip empty lines & comments
        next if /^$/ || /^#/;

        if (/^Host\s+(.+)/i) {
            # A Host line can contain multiple hostnames; use the first
            my @names = split /\s+/, $1;
            $current = $names[0];
            $hosts{$current} ||= {};
            next;
        }

        # Only parse key/value lines if we are inside a Host block
        if ($current && /^\s*(\S+)\s+(?:"((?:\\.|[^"\\])*)"|([^#\r\n]*))(?:\s*#.*)?\s*$/) {
            my ($key, $value) = ($1, defined $2 ? $2 : $3);
            $value =~ s/^\s+|\s+$//g if defined $value;
            $hosts{$current}{lc $key} = $value;
        }

    }

    close $fh;

    # Remove wildcard hosts from the returned data, as they are not directly connectable.
    delete @hosts{ grep /\*/, keys %hosts };

    # Ensure fundamental data is made present, even if not present in the configuration file.
    foreach my $host (keys %hosts) {
        $hosts{$host}{hostname} //= $host;
        $hosts{$host}{user} //= getlogin || getpwuid($<);
        $hosts{$host}{port} //= 22;
    }

    return \%hosts;
}

sub get_hosts_enriched {
    my $hosts_ref = get_hosts(@_);
    foreach my $host (keys %$hosts_ref) {
        my $base     = $hosts_ref->{$host} || {};
        my $enriched = _enrich_host($host) || {};
        $hosts_ref->{$host} = { %$base, %$enriched };
    }
    return $hosts_ref;
}

sub _enrich_host {
    my ($host) = @_;
    open my $fh, '-|', 'ssh', '-G', $host
        or die "ssh -G failed for '$host': $!";
    my @output = <$fh>;
    close $fh;
    my %enriched;

    foreach (@output) {
        chomp;
        s/^\s+|\s+$//g;
        next if /^$/ || /^#/;

        # Only parse key/value lines, assume no comments.
        if (/^(\S+)\s+(.*)$/) {
            my ($key, $value) = ($1, $2);
            $enriched{lc $key} = $value;
        }
    }

    return \%enriched;
}

sub get_maxlen {
    return max( map { length } @_ );
}

sub resolve_hostname {
    my ($hostname) = @_;

    my ($err, @res) = getaddrinfo(
        $hostname,
        undef,
        {
            family   => AF_UNSPEC,
            socktype => SOCK_STREAM,
        }
    );

    return if $err || !@res;

    my ($gni_err, $host, $service) = getnameinfo(
        $res[0]->{addr},
        NI_NUMERICHOST
    );

    return if $gni_err;
    return $host;
}

sub looks_true {
    my ($arg) = @_;
    return unless defined $arg;

    $arg =~ s/^\s+|\s+$//g;
    return $arg =~ /^(?:1|y|yes|true|on|enable|enabled)$/i;
}

sub is_x {
    confess('is_x($env, $opt) expects two arguments') unless @_ == 2;
    my $env = shift;
    my $opt = shift;
    return 1 if (defined $ENV{$env} && $ENV{$env} =~ m/$opt/xmsi);
    return 1 if (defined $ENV{$opt} && looks_true($ENV{$opt}));
    return 0;
}

sub check_port {
    my ($host, $port, $timeout) = @_;

    my $start = time();

    my $sock = IO::Socket::IP->new(
        PeerHost => $host,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => $timeout,
    );

    my $elapsed_ms = sprintf('%.2f', (time() - $start) * 1000);

    if ($sock) {
        close $sock;
        return {
            success => 1,
            error   => '',
            latency => $elapsed_ms,
        };
    }

    return {
        success => 0,
        error   => "$!",
        latency => $elapsed_ms,
    };
}

sub slurp {
    my ($filename) = @_;
    open my $fh, '<', $filename or die "Can't open $filename: $!";
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}


1;
