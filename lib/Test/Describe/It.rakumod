use Test;

class Test::Describe::It does Callable {
    has Str $.name;
    has     $.describe is rw handles <definitions>;
    has     &.block;

    method CALL-ME(*%pars) {
        subtest {
            my %keys is Set = &!block.signature.params.grep(*.named).map(*.name.subst: /^\W ** 1..2/, "");
            my %all-pars = %pars.grep({ %keys{ .key } });
            &!block.(|%all-pars, |(%pars<subject> if &!block.count));
            done-testing
        }, $!name
    }

    method list(UInt $num = 1) {
        "$num - $!name"
    }
}


