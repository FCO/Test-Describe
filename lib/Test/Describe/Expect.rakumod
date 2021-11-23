use Test;
use Test::Describe::Match;

class Test::Describe::Expect {
    has Mu $.value;

    multi method to(Test::Describe::Match $test) {
        self!run-test: |.<> for $test.subs
    }

    multi method not-to(Test::Describe::Match $test) {
        for $test.subs -> (&test, &msg) {
            self!run-test: { not test $_ }, { "not " ~ msg $_ }
        }
    }

    method !run-test(&test, &msg) {
        my Bool() $ok = test $!value;
        my $msg = msg $!value;
        if $ok {
            pass $msg
        } else {
            flunk $msg
        }
    }
}

