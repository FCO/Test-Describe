use Test::Describe::Match;

sub be-true is export {
    my $my-obj;
    Test::Describe::Match.new:
        :expected(True),
        test => -> Bool() $obj {
            $my-obj := $obj
        },
        msg => -> $actual {
            "expected to be true."
        },
    ;
}

sub be-false is export {
    my $my-obj;
    Test::Describe::Match.new:
        :expected(True),
        test => -> Bool() $obj {
            !($my-obj = $obj)
        },
        msg => -> $actual {
            "expected $my-obj to be false."
        },
    ;
}

sub have-method($meth-name) is export {
    my $my-obj;
    Test::Describe::Match.new:
        :expected($meth-name),
        test => -> $obj {
            $my-obj = $obj;
            so $obj.^can: $meth-name
        },
        msg => -> $actual {
            "expected { $my-obj.gist } to have method called $meth-name."
        },
    ;
}

sub matcher(&op) is export {
    sub ($expected is raw) {
        Test::Describe::Match.new:
            :$expected,
            test => -> $actual {
                op $actual, $expected
            },
            msg => -> $actual {
                "expected { &op.name }('$actual','$expected')."
            },
        ;
    }
}

multi change($expected is raw) is export {
    my $tmp;
    my $changed;
    my $result;
    Test::Describe::Match.new:
        :$expected,
        test => -> &val {
            $tmp = $expected;
            val;
            $changed = $expected;
            $result = $tmp !== $changed
        },
        msg => -> $actual {
            "expected to change { $expected.VAR.name } from '$tmp'{" to '$changed'" if $result }"
        }
}

multi change($expected is raw, $attr) is export {
    my $tmp;
    my $changed;
    my $result;
    Test::Describe::Match.new:
        :$expected,
        test => -> &val {
            $tmp = $expected."$attr"()<>;
            val;
            $changed = $expected."$attr"()<>;
            $result = $tmp !== $changed;
        },
        msg => -> $actual {
            "expected to change { $expected.VAR.name }.$attr from '$tmp'{" to '$changed'" if $result}"
        }
}

