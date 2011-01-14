package Resource;

use Moose;

use Carp qw( croak );

use overload '""', \&as_string;

has type => (
    is     => 'ro',
    isa    => 'Str',
    required => 1,
);

has stored => (
    is     => 'ro',
    isa    => 'Int',
    required => 1,
);

has per_hour => (
    is     => 'ro',
    isa    => 'Int',
    required => 1,
);

has capacity => (
    is     => 'ro',
    isa    => 'Int',
    predicate => 'has_capacity',
);



sub percent_capacity {
    my $self = shift;

    my $type = $self->type;

    croak "resource $type must have capacity to calculate percent_capacity()"
        unless $self->has_capacity;

    my $s = $self->stored;
    my $h = $self->per_hour;
    my $c = $self->capacity;

    my $p = int( 100 * $s / $c );

    return $p;
}

sub full {
    my $self = shift;

    my $type = $self->type;

    croak "resource $type must have capacity to be full"
        unless $self->has_capacity;

    my $s = $self->stored;
    my $c = $self->capacity;

    return $s == $c;
}

sub full_in {
    my $self = shift;

    my $type = $self->type;

    croak "resource $type  must have capacity to calculate full_in()"
        unless $self->has_capacity;

    my $s = $self->stored;
    my $h = $self->per_hour;
    my $c = $self->capacity;

    return if $h < 0;

    my $left = $c - $s;
    
    my $time_left = $left / $h; # hours

    return $time_left / 3600; # seconds
}

sub empty_in {
    my $self = shift;

    my $type = $self->type;

    my $s = $self->stored;
    my $h = $self->per_hour;

    return if $h < 0;

    my $time_left = $s / $h; # hours

    return $time_left / 3600; # seconds
}

sub as_string {
    my $self = shift;


    return sprintf "%s: %0d / %0d at %0d per hour", $self->type, $self->stored, $self->capacity, $self->per_hour
        if $self->has_capacity;

    return sprintf "%s: %0d at %0d per hour", $self->type, $self->stored, $self->per_hour
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
