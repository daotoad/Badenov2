package Star.pm;

use Moose;

has [qw( name id color )] => (
    is     => 'ro',
    isa    => 'Str',
);

has [qw(
    x
    y
)] => (
    is  => 'ro',
    isa => 'Int',
);

has bodies => (
    is     => 'ro',
    isa    => 'ArrayRef[Body]',
    lazy_build => 1,
    # /map get_star( session_id, star_id )
    # /map get_star_by_name( session_id, name )
    # /map get_star_by_xy( session_id, x, y )
);

has probed => (
    is     => 'ro',
    isa    => 'Bool',
    lazy_build => 1,
    # True if we get bodies, false if bodies queries offer no bodies.
);

has incoming_probe => (
    is     => 'ro',
    isa    => 'DateTime',
    lazy_build => 1,
    # /map check_star_for_incoming_probe( session_id, star_id )
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;
