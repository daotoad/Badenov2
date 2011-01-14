package LazyObject;
use Moose;
use Moose::Util::TypeConstraints;

use Scalar::Util qw( blessed );

subtype 'LazyObjectData' => as 'Int|Object';


    1;

has client => (
    is       => 'ro',
    isa      => 'Client',
    required => 1,
);

has class => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has builder => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has item => (
    isa       => 'Int|Object',
    predicate => 'has_item',
    clearer   => 'clear_item',
    writer    => '_set',
    reader    => '_get'
);


sub _promote {
    my $self = shift;

    my $value   = $self->_get;
    my $client  = $self->client;
    my $b_class = $self->class;
    my $build   = $self->builder;
    my $obj     = $b_class->$build( $client, $value );

    $self->_set( $obj );

    return unless defined $obj;
    return $obj;
}


sub get_item {
    my $self = shift;

    return unless $self->has_item;

    my $value   = $self->_get;
    return $value if blessed $value;

    return $self->_promote;
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
