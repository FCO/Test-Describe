[![Actions Status](https://github.com/FCO/Test-Describe/workflows/test/badge.svg)](https://github.com/FCO/Test-Describe/actions)

NAME
====

Test::Describe - blah blah blah

SYNOPSIS
========

```raku
use Test::Describe;

describe Int, {
    context "should have some methods", {
        define "is-prime-example", 42;
        define "a-code", 97;

        it "should have a working is-prime", -> :$described-class, :$is-prime-example {
            expect($described-class).to: have-method "is-prime";
            expect($is-prime-example).to: be-false;
        }

        it "should have a working is-prime", -> :$described-class, :$a-code {
            expect($described-class).to: have-method "is-prime";
            expect($a-code.chr).to: be-false;
        }
    }

    context "should work with math operators", {
        define "one-plus-one", { 1 + 1 };

        it "sum", -> &one-plus-one {
            expect(one-plus-one).to: be-eq 2
        }
    }
}
```

DESCRIPTION
===========

Test::Describe is ...

AUTHOR
======

    <foliveira@gocardless.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

