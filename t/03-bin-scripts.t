#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Test::More;
use File::Spec;

my $devnull    = File::Spec->devnull;

my @bins = glob("bin/*");

foreach my $bin (@bins) {
    ok(compile_check($bin)    == 0, "$bin compiles (perl -c)");
}

done_testing();

sub compile_check {
    my @cmd = @_;
    open my $null, '>', $devnull or die "Can't open $devnull: $!";
    my $pid = fork();
    if ($pid == 0) {
        open STDOUT, '>&', $null or die "Can't dup STDOUT: $!";
        open STDERR, '>&', $null or die "Can't dup STDERR: $!";
        exec $^X, '-c', @cmd or die "Can't exec: $!";
    }
    waitpid($pid, 0);
    my $ret = $? >> 8;
    return $ret;
}

1;
