package Empire.pm;

use Moose;


has [qw( id name status_message home_planet_id  )] => (
    is     => 'ro',
    isa    => 'Str',
);

has [qw(
    has_new_messages
    essentia
)] => (
    is  => 'ro',
    isa => 'Int',
);

has is_isolationist => (
    is     => 'ro',
    isa    => 'Bool',
);


has planets => (
    is     => 'ro',
    isa    => 'HashRef[Body]',
    traits => ['Hash'],
);

has newest_message => (
    is     => 'ro',
    isa    => 'Message',
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;
