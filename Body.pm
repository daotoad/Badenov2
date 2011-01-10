package Body.pm;

use Moose;

has buildings => (
    is     => 'ro',
    isa    => 'HashRef[Building]',
    traits => ['Hash'],
    lazy_build => 1,
);

has ore => (
    is     => 'ro',
    isa    => 'HashRef[Int]',
    traits => ['Hash'],
);

has empire => (
    is     => 'ro',
    isa    => 'Empire',
    lazy_build => 1,
);

has [qw( id name star_id type image )] => (
    is     => 'ro',
    isa    => 'Str',
);

has [qw(
    orbit
    size
    x
    y
    water
)] => (
    is  => 'ro',
    isa => 'Int',
);

has star => (
    is     => 'ro',
    isa    => 'Star',
    lazy_build => 1,
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;
