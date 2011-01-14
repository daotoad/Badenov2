package Point;

use Moose;
use Carp qw( croak );

use overload '""', \&as_string;

has [qw(
    x
    y
)] => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);


sub distance {
    my $class = shift if @_ == 3;
    my $source = shift;
    my $dest   = shift;

    croak "Both source and destination must be Point objects"
        unless $source->isa('Point') and $dest->isa('Point');

    my $dist = sqrt( ($source->x - $dest->x)**2 + ($source->y - $dest->y)**2 );

    return $dist;
}

sub as_string {
    my $self = shift;

    return sprintf "(%.3d,%.3d)", $self->x, $self->y;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
