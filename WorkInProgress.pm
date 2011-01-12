package WorkInProgress;

use Moose;
use Carp qw( croak );

#use overload '""', \&as_string;

#TODO make start and end into coercing DateTime objects

has seconds_remaining => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);

has start => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

has end => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
