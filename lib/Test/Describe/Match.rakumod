class Test::Describe::Match {
    has                       $.expected;
    has                       &.test;
    has                       &.msg = -> $actual { "expected '$!expected' but received '$actual'" }
    has Test::Describe::Match $.child;

    method and($val) {
        $!child = $val;
        self
    }

    method take-subs { take &!test, &!msg; .take-subs with $!child }
    method subs      { gather { $.take-subs } }
}

