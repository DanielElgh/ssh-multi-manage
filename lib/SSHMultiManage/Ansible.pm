package SSHMultiManage::Ansible;
# SPDX-License-Identifier: MIT

use strict;
use warnings;
use Carp qw(croak);

use Exporter 'import';
our @EXPORT_OK = qw(ansible_to_ssh ssh_to_ansible);


sub ansible_to_ssh {
    my $file = shift;

    my %data;
    my $current_tag = "unassigned";

    open my $fh, '<', $file or die "Can't open $file: $!";

    while (<$fh>) {
        chomp;
        s/^\s+|\s+$//g;

        # skip empty lines & comments
        next if /^$/ || /^#/;

        # Get group
        if (/^\[(\S+)]$/) {
            $current_tag = $1;
            next;
        }
        # Get config line
        if (/^(.+?)\s+(.+)/i) {
            my ($host, $config) = ($1, $2);
            push @{$data{$host}{tags}}, $current_tag;
            my @key_values = split /\s+/, $config;
            foreach my $keypair (@key_values) {
                my ($key, $value) = split /=/, $keypair, 2;
                $data{$host}{hostname} = $value if(lc $key eq 'ansible_host');
                $data{$host}{user} = $value if(lc $key eq 'ansible_user');
                $data{$host}{port} = $value if(lc $key eq 'ansible_port');
            }
        }
    }

    close $fh;

    # Print ssh config.
    foreach my $host (sort keys %data) {
        print "host $host\n";
        foreach my $key (sort keys %{$data{$host}}) {
            # Deal with tags separately.
            next if $key eq 'tags';
            print "\t$key $data{$host}{$key}\n";
        }
        if (exists $data{$host}{tags}[0] && $data{$host}{tags}[0] eq 'unassigned') {
            print "\n";
            next;
        }

        print "\t#tags" if (exists $data{$host}{tags});
        print " $_" foreach (@{$data{$host}{tags}});
        print "\n\n";
    }

    return 0;
}

sub ssh_to_ansible {
    my $host_ref = shift;

    my %data;

    # Step 1, identify the hosts and the assigned tags.

    foreach my $host (sort keys %$host_ref) {
        push @{$data{"ungrouped"}}, $host if !defined $host_ref->{$host}->{tags};
        foreach my $tag (grep { length } split /\s+/, ($host_ref->{$host}->{tags} // '')) {
            push @{$data{$tag}}, $host;
        }
    }

    # Step 2,
    foreach my $host (@{$data{"ungrouped"} // []}) {
        printf "%s ansible_host=%s ansible_user=%s ansible_port=%s\n",
            $host,
            $host_ref->{$host}->{hostname},
            $host_ref->{$host}->{user},
            $host_ref->{$host}->{port}
    }
    delete $data{"ungrouped"};
    foreach my $group (sort keys %data) {
        print "\n[$group]\n";
        foreach my $host (@{$data{$group}}) {
            printf "%s ansible_host=%s ansible_user=%s ansible_port=%s\n",
                $host,
                $host_ref->{$host}->{hostname},
                $host_ref->{$host}->{user},
                $host_ref->{$host}->{port}
        }
    }

    return 0;
}

1;
