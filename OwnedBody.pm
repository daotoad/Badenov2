package OwnedBody.pm;

use Moose::Role;

has needs_surface_refresh => (
    is     => 'ro',
    isa    => 'Bool',
);

has [qw( 
    building_count 
    plots_available 
    happiness 
    happiness_hour
    food_stored     food_capacity   food_hour
    energy_stored   energy_capacity energy_hour
    ore_stored      ore_capacity    ore_hour
    waste_stored    waste_capacity  waste_hour
    water_stored    water_capacity  water_hour
)] => (
    is     => 'ro',
    isa    => 'Int',
);

has incoming_foreign_ships => (
    is     => 'ro',
    isa    => 'ArrayRef[HashRef]',
    traits => ['Array'],
    lazy_build => 1,
);


no Moose::Role;
1;
