use Test;
use Test::Describe::It;

class Test::Describe::Describe is Test::Describe::It {
    has                    %.definitions;
    has Test::Describe::It @.its;
    has Callable           @.before;
    has Callable           @.after;

    multi method CALL-ME(+[Int $first, *@rest], *%pars) is test-assertion {
        my @before = @*BEFORE // ();
        my @after  = @*AFTER  // ();
        {
            my @*BEFORE = |@before, |@!before;
            my @*AFTER  = |@after , |@!after;
            subtest {
                plan 1;
                my %all-pars = |%pars, |%!definitions;
                @!its[$first - 1].(|@rest, |%all-pars);
            }, $.name
        }
    }

    multi method CALL-ME(*%pars) is test-assertion {
        my @before = @*BEFORE // ();
        my @after  = @*AFTER  // ();
        {
            my @*BEFORE = |@before, |@!before;
            my @*AFTER  = |@after , |@!after;
            subtest {
                plan +@!its;
                my %all-pars = |%pars, |%!definitions;
                do for @!its -> &it {
                    it |%all-pars
                }
            }, $.name
        }
    }

    method list(UInt $num = 1) {
        (
            "$num - $.name",
            @!its.kv.map(-> $i, $_ { .list: $i + 1 }).join("\n").indent(3)
        ).join: "\n"
    }
}

