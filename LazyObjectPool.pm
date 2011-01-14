package LazyObjectPool;
use Moose;
use Moose::Util::TypeConstraints;

use Scalar::Util qw( blessed );

subtype 'LazyObjectStore' => as 'HashRef[Int|Object]';

coerce 'LazyObjectStore'
    => from 'ArrayRef[Int]' 
    => via {
        my %store = map {($_,$_)} @$_;
        return \%store;
    };

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

has store => (
    is       => 'ro',
    isa      => 'LazyObjectStore',
    traits   => ['Hash'],
    required => 1,
    default  => sub {{}},
    handles  => {
        _set_store => 'set',
        _get_store => 'get',
        keys       => 'keys',
        values     => 'values',
        has        => 'exists',
    },
    coerce => 1,
);


sub _promote_key {
    my $self = shift;
    my $key  = shift;

    my $client  = $self->client;
    my $b_class = $self->class;
    my $build   = $self->builder;
    my $obj     = $b_class->$build( $client, $key );

    $self->_set_store( $key, $obj );

    return unless defined $obj;
    return $obj;
}


sub get {
    my $self = shift;
    my $key  = shift;

    return unless $self->has( $key );

    my $val = $self->_get_store( $key );
    return $val if blessed $val;

    return $self->_promote_key( $key );
}

sub members {
    my $self = shift;

    return map { 
        blessed $_ ? $_ : $self->_promote_key($_)
    } $self->values;
}

__PACKAGE__->meta->make_immutable;
1;
