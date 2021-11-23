use Test;
use Test::Describe::Describe;

class Test::Describe::Root is Test::Describe::Describe {
    method list {
        @.its.kv.map(-> $i, $_ { .list: $i + 1 }).join("\n")
    }

    multi method CALL-ME(+[Int $first, *@rest], *%pars) {
        plan 1;
        my %all-pars = |%pars, %.definitions;
        @.its[$first - 1].(|@rest, |%all-pars);
    }

    multi method CALL-ME(*%pars) {
        plan +@.its;
        my %all-pars = |%pars, %.definitions;
        do for @.its -> &it {
            it |%all-pars
        }
    }
}

