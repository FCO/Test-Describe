use Test::Describe::Helpers;
use Test::Describe::Match;
use Test::Describe::Match::Change;

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
            "expected $my-obj.&prepare-to-print() to be false."
        },
    ;
}

sub smart-match($expected) is export {
    my $my-obj;
    Test::Describe::Match.new:
        :expected($expected),
        test => -> $obj {
            $my-obj = $obj;
            so $obj ~~ $expected
        },
        msg => -> $actual {
            "expected $my-obj.&prepare-to-print() to smart-match $expected.&prepare-to-print()."
        },
    ;
}

sub be-of-type(Mu:U $type) is export {
    my $my-obj;
    Test::Describe::Match.new:
        :expected($type),
        test => -> $obj {
            $my-obj = $obj;
            so $obj.^isa: $type
        },
        msg => -> $actual {
            "expected $my-obj.&prepare-to-print() to be of type $type.^name()."
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
            "expected { $my-obj.&prepare-to-print } to have method called $meth-name."
        },
    ;
}

sub matcher(&op) is export {
    sub prepare-msg(&op, $actual, $expected) {
        &op.name ~~ /^$<type>=\w+ ":" "<" ~ ">" $<op>=.+$/;
        my $exp = do given $<type> {
            when "infix" {
                "{ $expected.&prepare-to-print } { $<op> } { $actual.&prepare-to-print }"
            }
            default {
                "{ &op.name }({ $expected.&prepare-to-print }, { $actual.&prepare-to-print() })"
            }
        }
        "expected `$exp` be true"
    }
    sub ($expected is raw) {
        Test::Describe::Match.new:
            :$expected,
            test => -> $actual {
                op $actual, $expected
            },
            msg => -> $actual {
                prepare-msg &op, $actual, $expected
            },
            hint => -> $actual {
                qq:to/END/
                \o33[33;1mexpected: $expected.gist()\o33[m
                \o33[33;1mactual  : $actual.gist()\o33[m
                \o33[33;1mop      : &op.name()\o33[m
                END
            },
        ;
    }
}

multi change($value is raw) is export {
    Test::Describe::Match::Change.new:
        :$value,
    ;
}

multi change($value is raw, $attr) is export {
    Test::Describe::Match::Change.new:
        :$value,
        :$attr,
    ;
}

