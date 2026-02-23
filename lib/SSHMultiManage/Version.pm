package SSHMultiManage::Version;
# SPDX-License-Identifier: MIT

use strict;
use warnings;
use version;
use Carp qw(croak);

use Exporter 'import';
our @EXPORT_OK = qw(print_version);

our $VERSION      = version->declare("v1.0.0");
our $COPYRIGHT    = 'Copyright (C) 2025, 2026 Daniel Elgh';
our $LICENSE      = 'MIT';
our $LICENSE_LONG = <<'END_LICENSE';
License: MIT
This is free software; you may redistribute it under the terms of the MIT License.
There is NO WARRANTY, to the extent permitted by law.
END_LICENSE

sub print_version {
    croak "version() needs a name argument" unless @_ >= 1;
    my $name = shift;
    print "$name $SSHMultiManage::Version::VERSION\n";
    print "$SSHMultiManage::Version::COPYRIGHT\n";
    print "$SSHMultiManage::Version::LICENSE_LONG";
    return 0;
}


1;
