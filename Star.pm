package Star;

use Moose;

has [qw( name id color )] => (
    is     => 'ro',
    isa    => 'Str',
);

has location => (
    is  => 'ro',
    isa => 'Point',
);

has bodies => (
    isa    => 'LazyObjectPool',
    handles => {
        bodies   => 'members',
        get_body => 'get',
        body_ids => 'keys',
        has_body => 'has',
    },
    predicate => 'probed',
);


sub new_from_id {
    my $class  = shift;
    my $client = shift;
    my $id     = shift;

    warn "Making STAR from $id\n";

    my $s = $client->get_star( $id );

    use Data::Dumper;
    warn Dumper $s;


    my $d = $s->data;

    my %args; 
    {   my @attrs = qw( id name color  );
        @args{@attrs} = @{$d}{@attrs};
        $args{location} = Point->new( x => $d->{x}, y => $d->{y} );

        $args{bodies} = LazyObjectPool->new(
            client  => $client,
            class   => 'Body',
            builder => 'new_from_id',
            store   => $d->{bodies},
        ) if exists $d->{bodies};

    }



    $class->new( %args );
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;
