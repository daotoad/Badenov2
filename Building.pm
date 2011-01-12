package Building;

use Moose;
use Point;
use WorkInProgress;

use Carp qw( croak );


has name => (
    is     => 'ro',
    isa    => 'Str',
    lazy_build => 1,
);

has location => (
    is     => 'ro',
    isa    => 'Point',
    handles => [qw( x y )],
);

has url => (
    is     => 'ro',
    isa    => 'Str',
);

has level => (
    is     => 'ro',
    isa    => 'Int',
);

has image => (
    is  => 'ro',
    isa => 'Str',
);

has efficiency => (
    is  => 'ro',
    isa => 'Int',
);

has pending_build => (
    is  => 'ro',
    isa => 'WorkInProgress',
);

has work => (
    is  => 'ro',
    isa => 'WorkInProgress',
);



sub new_from_id {
    my $class  = shift;
    my $client = shift;
    my $id     = shift;

    my $bs = $client->get_building_status( $id );

    my $d = $bs->data;

    my %args; 
    {   my @attrs = qw( id name url level image efficiency );
        @args{@attrs} = @{$d}{@attrs};
        $args{location} = Point->new( x => $d->{x}, y => $d->{y} );

        $args{pending_build} = WorkInProgress->new( %{$d->{pending_build}})
            if exists $d->{pending_build};

        $args{work} = WorkInProgress->new( %{$d->{work}})
            if exists $d->{work};
    }

    $class->new( %args );
}


1;
