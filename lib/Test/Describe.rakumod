use Test;

class Test::Describe {...}

class Test::It does Callable {
    has                $.name;
    has Test::Describe $.describe is rw handles <definitions>;
    has                &.block;

    method CALL-ME(*%pars) {
        subtest {
            my %keys is Set = &!block.signature.params.grep(*.named).map(*.name.subst: /^\W ** 1..2/, "");
            my %all-pars = %pars.grep({ %keys{ .key } });
            &!block.(|%all-pars);
            done-testing
        }, $!name
    }

    method list(UInt $num = 1) {
        "$num - $!name"
    }
}

class Test::Describe is Test::It {
    has          %.definitions;
    has Test::It @.its;

    multi method CALL-ME(+[Int $first, *@rest], *%pars) {
        subtest {
            my %all-pars = |%pars, %!definitions;
            @!its[$first - 1].(|@rest, |%all-pars);
            done-testing
        }, $.name
    }

    multi method CALL-ME(*%pars) {
        subtest {
            plan +@!its;
            my %all-pars = |%pars, %!definitions;
            do for @!its -> &it {
                it |%all-pars
            }
            done-testing
        }, $.name
    }

    method list(UInt $num = 1) {
        (
            "$num - $.name",
            @!its.kv.map(-> $i, $_ { .list: $i + 1 }).join("\n").indent(3)
        ).join: "\n"
    }
}

class Test::Root is Test::Describe {
    method list {
        @.its.kv.map(-> $i, $_ { .list: $i + 1 }).join("\n")
    }
}

my &ROOT = my $DESCRIBE = Test::Root.new;

multi MAIN(Bool :$list-tests! where .so) {
    say &ROOT.list
}

multi MAIN(+@nums) {
    ROOT |@nums
}

multi MAIN() {
    ROOT
}

multi describe(Mu:U $type, &block) {
    $DESCRIBE.definitions<subject> = $type;
    describe $type.^name, &block
}

multi describe(Any $type, &block) {
    $DESCRIBE.definitions<subject> = $type;
    $DESCRIBE.definitions<described-class> = $type;
    describe $type.^name, &block
}

multi describe(Str $name, &block) {
    my $describe = $DESCRIBE;
    $describe.its.push: $DESCRIBE = Test::Describe.new: :$name, |(:$describe with $describe);
    block;
    $DESCRIBE = $describe
}

sub define(Str $name, \value) {
    $DESCRIBE.definitions{ $name } := value
}

multi it(Str $name, &block) {
    $DESCRIBE.its.push: Test::It.new: :$name, :&block
}

class Test::Match {
    has             $.expected;
    has             &.test;
    has             &.msg = -> $actual { "expected '$!expected' but received '$actual'" }
    has Test::Match $.child;

    method and($val) {
        $!child = $val;
        self
    }

    method take-subs { take &!test, &!msg; .take-subs with $!child }
    method subs      { gather { $.take-subs } }
}

class Test::Expect {
    has $.value;

    multi method to(Test::Match $test) {
        self!run-test: |.<> for $test.subs
    }

    multi method not-to(Test::Match $test) {
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

sub expect($value) {
    Test::Expect.new: :$value
}

sub matcher(&op) {
    sub ($expected is raw) {
        Test::Match.new:
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

multi change($expected is raw) {
    my $tmp;
    my $changed;
    my $result;
    Test::Match.new:
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

multi change($expected is raw, $attr) {
    my $tmp;
    my $changed;
    my $result;
    Test::Match.new:
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

sub EXPORT(--> Map()) {
    "&MAIN"     => &MAIN,
    "&describe" => &describe,
    "&context"  => &describe,
    "&it"       => &it,
    "&define"   => &define,
    Test::EXPORT::ALL::,
    '&expect'   => &expect,
    '&change'   => &change,
    '&be'       => matcher(&[===]),
    '&be-eq'    => matcher(&[==]),
}

=begin pod

=head1 NAME

Test::Describe - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use Test::Describe;

=end code

=head1 DESCRIPTION

Test::Describe is ...

=head1 AUTHOR

 <foliveira@gocardless.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
