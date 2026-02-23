#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Test::More;

use_ok('SSHMultiManage::Version');
can_ok('SSHMultiManage::Version', qw(print_version));

ok(SSHMultiManage::Version::print_version('x') == 0);

done_testing();

1;
