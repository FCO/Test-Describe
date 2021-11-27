use Test::Describe::Match;
use Test::Describe::Helpers;

class Test::Describe::Match::Change is Test::Describe::Match {
    has &.value;
    has $!use-from = False;
    has $!use-to   = False;
    has $!from;
    has $!to;

    has $!msg = "should changed";
    has $!obj;

    has Str $!var-name;

    multi method BUILD(:$value! is raw, Str :$attr!) {
        &!value := sub () is raw {
            $!var-name = "{ $value.VAR.name }.{ $attr }";
            $value."$attr"()
        }
    }

    multi method BUILD(:$value! is raw) {
        &!value := sub () is raw {
            $!var-name = $value.VAR.name;
            $value
        }
    }

    method test {
        sub (&changer) {
            my $from = &!value.();
            if $!use-from && $!from !eqv $from {
                $!msg = "{ self!get-var-name } wasn't $!from.&prepare-to-print() before changing";
                return False
            }
            $!from = $from;
            changer();
            my $to = &!value.();
            if $from eqv $to {
                $!msg = "{ self!get-var-name } has not changed";
                return False
            }
            if $!use-to && $!to !eqv $to {
                $!msg = "{ self!get-var-name } wasn't $!to.&prepare-to-print() after changing";
                return False
            }
            $!to = $to;
            True
        }
    }
    method msg {
        -> $ { $!msg }
    }

    method hint {
        -> $ {
            qq:to/END/
            \o33[33mfrom: $!from.gist()\o33[m
            \o33[33mto  : $!to.gist()\o33[m
            END
        }
    }

    method take-subs { take self.test, self.msg, self.hint; .take-subs with $.child }

    method !get-var-name {
        my \val = &!value.();
        $!var-name // val.&prepare-to-print
    }

    method from($from where not $!from.defined) {
        $!from = $from;
        $!use-from = True;
        self
    }

    method to($to where not $!to.defined) {
        $!to = $to;
        $!use-to = True;
        self
    }
}
