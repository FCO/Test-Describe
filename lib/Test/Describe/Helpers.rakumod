sub filter-params-for(&block, %params --> Hash()) is export {
    my @block-params = &block.signature.params;
    return %params if @block-params>>.&{ .slurpy && .name.starts-with: "%" }.any.so;
    my %keys is Set = @block-params.grep(*.named).map: |*.named_names;
    %params.grep({ %keys{ .key } });
}

sub call-with-filtered-params(&block, %params) is export {
    my $subject = %params<subject>;
    my %new-params = prepare-params filter-params-for(&block, %params), %params;
    block |(prepare-param $subject, %params if &block.count), |%new-params
}

sub prepare-params(%params, %all-params --> Hash()) {
    do for %params.kv -> $key, $value {
        $key => prepare-param $value, %all-params
    }
}

sub prepare-param($value, %all-params) is export {
    do if $value ~~ Callable {
        my %cache;
        my %new-params = filter-params-for($value, %all-params);
        -> $subject?, *%named {
            my %p = |%new-params, |%named;
            %cache{[$subject, %named.sort].gist} //= $value.(
                |(
                    $subject // %new-params<subject> // () if $value.count
                ),
                |%p
            )
        }
    } else {
        $value
    }
}

sub prepare-to-print($obj) is export {
    my $gist = $obj.gist;
    $gist.substr: 0, $gist.index("(") min 35
}
