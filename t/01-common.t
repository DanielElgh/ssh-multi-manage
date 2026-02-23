#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Test::More;
use File::Temp qw(tempfile);

use_ok('SSHMultiManage::Common');
can_ok('SSHMultiManage::Common', qw(get_config_file arg_match get_hosts get_hosts_enriched get_maxlen looks_true is_x check_port resolve_hostname slurp));

use SSHMultiManage::Common qw(looks_true);

subtest 'arg_match' => sub {
    my @test = qw(--help --foo asdf asdf asdfgh);
    my $return = SSHMultiManage::Common::arg_match(\@test, qw(--help));
    ok($return, "--help present");
    $return = SSHMultiManage::Common::arg_match(\@test, qw(--help));
    ok(!$return, "--help no longer present");
};

subtest 'looks_true' => sub {
    ok(looks_true('yes'),   "looks_true returns true");
    ok(looks_true('YES'),   "looks_true returns true");
    ok(looks_true('True'),  "looks_true returns true");
    ok(looks_true('enable'),  "looks_true returns true");
    ok(looks_true('enabled'), "looks_true returns true");
    ok(looks_true('1'),     "looks_true returns true");
    ok(looks_true(1),       "looks_true returns true");
    ok(looks_true('on'),    "looks_true returns true");
    ok(looks_true('yes '),  "looks_true returns true");
    ok(looks_true(' YES '), "looks_true returns true");
    ok(looks_true('y'),     "looks_true returns true");

    ok(!looks_true('false'), "looks_true returns false");
    ok(!looks_true('no'),    "looks_true returns false");
    ok(!looks_true('nope'),  "looks_true returns false");
    ok(!looks_true('disable'),  "looks_true returns false");
    ok(!looks_true('disabled'), "looks_true returns false");
    ok(!looks_true('n'),     "looks_true returns false");
    ok(!looks_true('0'),     "looks_true returns false");
    ok(!looks_true(0),       "looks_true returns false");
    ok(!looks_true('11'),    "looks_true returns false");
    ok(!looks_true('off'),   "looks_true returns false");
    ok(!looks_true(''),      "looks_true returns false");
    ok(!looks_true(undef),   "looks_true returns false");
    ok(!looks_true(),        "looks_true returns false");
};

subtest 'get_config_file env override' => sub {
    my ($fh, $tmpfile) = tempfile();
    close $fh;

    local $ENV{CONNECT_CONFIG_FILE} = $tmpfile;
    my $resolved = SSHMultiManage::Common::get_config_file();
    is($resolved, $tmpfile, 'uses CONNECT_CONFIG_FILE when present and existing');
};


subtest 'check_port against a closed port' => sub {
    # Use a very high random port that is almost certainly closed
    my $result = SSHMultiManage::Common::check_port('127.0.0.1', 39_999, 0.5);
    ok(defined $result, 'returns a result');
    is(ref $result, 'HASH', 'result is a hash ref');
    ok(exists $result->{success}, 'has success key');
    ok(exists $result->{latency}, 'has latency key');
    ok(exists $result->{error}, 'has error key');
};

subtest 'get_maxlen' => sub {
    is(SSHMultiManage::Common::get_maxlen('a', 'bb', 'ccc'), 3, 'max of lengths');
    is(SSHMultiManage::Common::get_maxlen('hello'), 5, 'single element');
};

subtest 'slurp reads file contents' => sub {
    my ($fh, $tmpfile) = tempfile(UNLINK => 1);
    print $fh "hello world\nrow2";
    close $fh;

    my $content = SSHMultiManage::Common::slurp($tmpfile);
    is($content, "hello world\nrow2", 'slurp returns file contents');
};

subtest 'slurp dies on missing file' => sub {
    eval { SSHMultiManage::Common::slurp('/tmp/nonexistent_file_' . $$) };
    like($@, qr/Can't open/, 'dies with meaningful error');
};



done_testing();

1;
