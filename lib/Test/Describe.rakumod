use Test;
use Test::Describe::It;
use Test::Describe::Root;
use Test::Describe::Match;
use Test::Describe::Expect;
use Test::Describe::Describe;
use Test::Describe::MatchFunctions;

my &ROOT = my $DESCRIBE = Test::Describe::Root.new;

my Test::Describe::Describe %examples;

multi MAIN(Bool :$list-tests! where .so) {
    say &ROOT.list
}

multi MAIN(+@nums) {
    ROOT |@nums
}

multi MAIN() {
    ROOT
}

sub shared-example(Str $name, &block) {
    my $describe = $DESCRIBE;
    %examples{ $name } = $DESCRIBE = Test::Describe::Describe.new: :$name, |(:$describe with $describe);
    block;
    $DESCRIBE = $describe
}

sub it-behaves-like(Str $name, *%pars) {
    my $ex = %examples{ $name };
    $DESCRIBE.its.push: $ex.clone: :definitions(%( |$ex.definitions, |%pars ))
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
    $describe.its.push: $DESCRIBE = Test::Describe::Describe.new: :$name, |(:$describe with $describe);
    block;
    $DESCRIBE = $describe
}

sub define(Str $name, \value) {
    $DESCRIBE.definitions{ $name } := value
}

multi it(Str $name, &block) {
    $DESCRIBE.its.push: Test::Describe::It.new: :$name, :&block
}

sub expect($value) {
    Test::Describe::Expect.new: :$value
}

sub EXPORT(--> Map()) {
    Test::EXPORT::ALL::,
    "&MAIN"            => &MAIN,
    "&shared-example"  => &shared-example,
    "&it-behaves-like" => &it-behaves-like,
    "&describe"        => &describe,
    "&context"         => &describe,
    "&it"              => &it,
    "&define"          => &define,
    "&subject"         => &define,
    '&expect'          => &expect,
    '&change'          => &change,
    '&have-method'     => &have-method,
    '&be-true'         => &be-true,
    '&be-false'        => &be-false,
    '&be'              => matcher(&[===]),
    '&be-eq'           => matcher(&[==]),
    '&be-gt'           => matcher(&[>]),
    '&be-lt'           => matcher(&[<]),
    '&be-ge'           => matcher(&[>=]),
    '&be-le'           => matcher(&[<=]),
    '&be-str-eq'       => matcher(&[eq]),
    '&be-str-gt'       => matcher(&[gt]),
    '&be-str-lt'       => matcher(&[lt]),
    '&be-str-ge'       => matcher(&[ge]),
    '&be-str-le'       => matcher(&[le]),
}

=begin pod

=head1 NAME

Test::Describe - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

Test::Describe is ...

=head1 AUTHOR

 Fernando Correa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
