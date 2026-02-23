#!/usr/bin/env perl
# Tests for lssrv helper functions (loaded via require)
use strict;
use warnings;
use Test::More;
use FindBin;

# Load helper subs from bin/lssrv without running main()
# (bin/lssrv uses: exit main(@ARGV) unless caller;)
require "$FindBin::Bin/../bin/lssrv";

subtest 'filter_row no filters matches all' => sub {
    my @row = ('host', '10.0.0.1', 'prod', 'Ubuntu', '5d');
    ok(filter_row(\@row, []), 'empty filters matches');
};

subtest 'filter_row single matching filter' => sub {
    my @row = ('webhost', '10.0.0.1', 'prod', 'Ubuntu 24.04', '5d');
    ok(filter_row(\@row, ['prod']), 'matches tag');
    ok(filter_row(\@row, ['web']),  'matches partial host');
    ok(filter_row(\@row, ['Ubuntu']), 'matches OS');
};

subtest 'filter_row non-matching filter' => sub {
    my @row = ('webhost', '10.0.0.1', 'prod', 'Ubuntu', '5d');
    ok(!filter_row(\@row, ['staging']), 'no match returns false');
};

subtest 'filter_row multiple filters (AND)' => sub {
    my @row = ('webhost', '10.0.0.1', 'prod', 'Ubuntu', '5d');
    ok(filter_row(\@row, ['prod', 'web']), 'both match');
    ok(!filter_row(\@row, ['prod', 'staging']), 'one miss fails');
};

subtest 'filter_row is case-insensitive' => sub {
    my @row = ('WebHost', '10.0.0.1', 'PROD', 'Ubuntu', '5d');
    ok(filter_row(\@row, ['prod']), 'case insensitive');
    ok(filter_row(\@row, ['webhost']), 'case insensitive host');
};

subtest 'filter_row handles regex special chars' => sub {
    my @row = ('host(1)', '10.0.0.1', '', '', '');
    ok(filter_row(\@row, ['host(1)']), 'regex chars are escaped');
    ok(!filter_row(\@row, ['host(2)']), 'non-match still fails');
};

subtest 'cleanup_uptime strips prefix' => sub {
    is(cleanup_uptime('up 5 days'), '5d', 'days');
    is(cleanup_uptime('up 1 day'), '1d', 'singular day');
    is(cleanup_uptime('up 2 weeks, 3 days, 4 hours'), '2w, 3d, 4h', 'compound');
    is(cleanup_uptime('up 10 minutes'), '10m', 'minutes');
    is(cleanup_uptime('up 1 hour, 30 minutes'), '1h, 30m', 'hours + minutes');
};

done_testing();

1;
