use Test;
use Test::Describe::Match;

class Test::Describe::Expect {
    has Mu $.value;

    multi method to(Test::Describe::Match $test) {
        self!run-test: |.<> for $test.subs
    }

    multi method not-to(Test::Describe::Match $test) {
        for $test.subs -> (&test, &msg, &hint?) {
            self!run-test:
                -> $expected { not test $expected },
                -> $expected { "not " ~ msg $expected },
                &hint
        }
    }

    method !run-test(&test, &msg, &hint?) {
        die "Matching outside a it block" unless $*IT;
        my Bool() $ok = test $!value;
        my $msg = msg $!value;
        if $ok {
            pass $msg;
        } else {
            flunk $msg;
            diag "\o33[31;1mERROR on it block at: {$*IT.file}:{ $*IT.line }\o33[m";
            diag .($!value) with &hint
        }
    }
}

