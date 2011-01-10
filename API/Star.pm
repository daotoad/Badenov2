package API::Star;
use Moose;

use Cached;
with 'Cached';

our $VERSION = '0.01';

sub expiration_hours   { 2 }
sub expiration_minutes { 0 } 
sub expiration_seconds { 0 }

sub cache_path { ['star'] }

has [qw( name color )] => ( 
    is => 'ro',
    isa => 'Str',
);

has [qw( id )] => ( 
    is => 'ro',
    isa => 'Int',
    lazy_build => 1,
);

has [qw( has_new_messages essentia )] => ( 
    is => 'ro',
    isa => 'Int',
);

has planets => ( 
    is => 'ro',
    isa => 'HashRef',
    lazy_build => 1,
);

has most_recent_message => ( 
    is => 'ro',
    isa => 'HashRef',
);

sub _build_id {
    my $self = shift;

    if( $self->has_name ) {
        $self->client->get_star_by_name( $self->name );
    }

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
