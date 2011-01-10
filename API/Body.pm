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
