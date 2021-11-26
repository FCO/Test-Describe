use Test;
use Test::Describe::Helpers;

class Test::Describe::It does Callable {
    has Str $.name;
    has     $.describe is rw handles <definitions>;
    has     &.block handles <line file>;

    method CALL-ME(*%pars) is test-assertion {
        my $*IT = self;
        my @before;
        with @*BEFORE {
            prepare-param($_, %pars).() for .<>
        }
        my @after;
        with @*AFTER {
            prepare-param($_, %pars).() for .<>
        }

        subtest {
            call-with-filtered-params &!block, %pars;
            done-testing
        }, $!name;

        for @after -> &after {
            after
        }
    }

    method list(UInt $num = 1) {
        "$num - $!name"
    }
}
