use Test;
use Test::Describe::Helpers;

class Test::Describe::It does Callable {
    has Str $.name;
    has     $.describe is rw handles <definitions>;
    has     &.block handles <line file>;

    method CALL-ME(*%pars) is test-assertion {
        my $*IT = self;
        subtest {
            call-with-filtered-params &!block, %pars;
            done-testing
        }, $!name
    }

    method list(UInt $num = 1) {
        "$num - $!name"
    }
}


