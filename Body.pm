package Body;

use Moose;
use Point;
use Resource;

use Carp qw( croak );

has buildings => (
    is     => 'ro',
    isa    => 'HashRef[Building]',
    traits => ['Hash'],
    lazy_build => 1,
);

has ore => (
    is     => 'ro',
    isa    => 'HashRef[Int]',
    traits => ['Hash'],
);

has empire => (
    is     => 'ro',
    isa    => 'Empire',
    lazy_build => 1,
);

has orbit => (
    is     => 'ro',
    isa    => 'Int',
);

has [qw( id name star_id type image )] => (
    is     => 'ro',
    isa    => 'Str',
);

has [qw(
    orbit
    size
    water
)] => (
    is  => 'ro',
    isa => 'Int',
);

has location => (
    is     => 'ro',
    isa    => 'Point',
    handles => [qw( x y )],
);

has star => (
    is     => 'ro',
    isa    => 'Int',
    lazy_build => 1,
);


# --- 
# Owned

has [qw( food ore water energy waste happiness )] => (
    is => 'ro',
    isa => 'Resource',
);




sub new_from_id {
    my $class  = shift;
    my $client = shift;
    my $id     = shift;

    my $bs = $client->get_body_status( $id );

    my $d = $bs->data;

    my %args; 
    {   my @attrs = qw( id orbit type name image size water ore );
        @args{@attrs} = @{$d}{@attrs};
        $args{location} = Point->new( x => $d->{x}, y => $d->{y} );
    }

    my %owned; 
    {   my @attrs = qw( building_count plots_available );
        @owned{@attrs} = @{$d}{@attrs};

        $owned{happiness} = Resource->new( 
            type     => 'happiness',
            per_hour => $d->{happiness_hour}, 
            stored   => $d->{happiness}
        );

        $owned{food} = Resource->new( 
            type     => 'food',
            per_hour => $d->{food_hour}, 
            stored   => $d->{food_stored},
            capacity => $d->{food_capacity}
        );

        $owned{energy} = Resource->new( 
            type     => 'energy',
            per_hour => $d->{energy_hour}, 
            stored   => $d->{energy_stored},
            capacity => $d->{energy_capacity}
        );

        $owned{ore} = Resource->new( 
            type     => 'ore',
            per_hour => $d->{ore_hour}, 
            stored   => $d->{ore_stored},
            capacity => $d->{ore_capacity}
        );

        $owned{water} = Resource->new( 
            type     => 'water',
            per_hour => $d->{water_hour}, 
            stored   => $d->{water_stored},
            capacity => $d->{water_capacity}
        );

        $owned{waste} = Resource->new( 
            type     => 'waste',
            per_hour => $d->{waste_hour}, 
            stored   => $d->{waste_stored},
            capacity => $d->{waste_capacity}
        );
    }



    $class->new( %args, %owned );
}


1;
