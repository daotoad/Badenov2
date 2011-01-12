BEGIN {
    package API::BodyStatus;
    use Moose;

    use Carp qw(croak);
    use API::Object;

    with 'API::ObjectWithID';


    sub path {
        my $inv = shift;
        my $id  = shift;

        croak "Unable to get body id"
            unless defined $id;
        
        return "status/body/$id";
    }

    sub expiration {
        return minutes => 30;
    }

    sub id_key { 'id' }

    sub name {
        my $self = shift;

        my $d = $self->data;
        my $name = $d->{name};
        return $name;
    }

    sub resource_summary {
        my $self = shift;

        my $d = $self->data;

        my %rs = (
            ore      => [ @{$d}{qw( ore_hour       ore_stored    ore_capacity    )} ],
            food     => [ @{$d}{qw( food_hour      food_stored   food_capacity   )} ],
            energy   => [ @{$d}{qw( energy_hour    energy_stored energy_capacity )} ],
            water    => [ @{$d}{qw( water_hour     water_stored  water_capacity  )} ],
            waste    => [ @{$d}{qw( waste_hour     waste_stored  waste_capacity  )} ],
            happines => [ @{$d}{qw( happiness_hour happiness                     )} ],
        ); 

        return \%rs;
    }

    __PACKAGE__->meta->make_immutable;
    no Moose;
    1;
}

BEGIN {
    package API::BodyBuildings;
    use Moose;

    use Carp qw(croak);
    our @CARP_NOT = qw(
        Class::MOP::Method::Wrapped
    );

    use API::Object;

    with 'API::ObjectWithID';

    sub path {
        my $inv = shift;
        my $id  = shift;

        croak "Unable to get body id"
            unless defined $id;
        
        return "body/$id/buildings";
    }

    sub expiration {
        return minutes => 30;
    }

    sub id_key { 'id' }

    sub buildings {
        my $self = shift;

        my $d = $self->data;
        return @{ $d->{buildings} };
    }

    __PACKAGE__->meta->make_immutable;
    no Moose;
    1;
}


BEGIN {
    package API::BuildingStatus;
    use Moose;

    use Carp qw(croak);
    use API::Object;

    with 'API::ObjectWithID';

    sub path {
        my $inv = shift;
        my $id  = shift;

        croak "Unable to get building id"
            unless defined $id;
        
        return "building/$id/status";
    }

    sub expiration {
        return minutes => 30;
    }

    sub id_key { 'id' }

    __PACKAGE__->meta->make_immutable;
    no Moose;
    1;
}

1;
