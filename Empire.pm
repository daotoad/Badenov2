package Empire;

use Moose;
use LazyObjectPool;


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
    isa    => 'LazyObjectPool',
    handles => {
        planets    => 'members',
        get_planet => 'get',
        planet_ids => 'keys',
        has_planet => 'has',
    },
);

has newest_message => (
    is     => 'ro',
    isa    => 'Message',
);

sub home_planet {
    my $self = shift;

    my $p = $self->get_planet( $self->home_planet_id );

    return $p;
}

sub get_mine {
    my $class = shift;
    my $client = shift;

    my $es = $client->get_empire_status;

    my $d = $es->data;
    
    my %args; 
    {   my @attrs = qw( 
            id name is_isolationist home_planet_id 
            status_message has_new_messages essentia
        );
        @args{@attrs} = @{$d}{@attrs};

        $args{planets} = LazyObjectPool->new(
            client  => $client,
            class   => 'Body',
            builder => 'new_from_id',
            store   => [ keys %{$d->{planets}} ],
        );
    }

    return $class->new( %args );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
