package API::Star;
use Moose;

use Carp qw( croak );

use API::Object;

with 'API::ObjectWithID';

sub path {
    my $inv = shift;
    my $id  = shift;

    croak "Unable to get body id"
        unless defined $id;
    
    return "star/$id";
}

sub expiration {
    return hours => 2;
}

sub id_key { 'id' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
