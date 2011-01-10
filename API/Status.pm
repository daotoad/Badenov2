
BEGIN {
    package API::EmpireStatus;
    use Moose;

    use Carp qw(croak);
    use API::Object;

    with 'API::Object';


    sub path { "status/empire" }
    sub expiration { minutes => 30 }
    


    sub planets {
        my $self = shift;

        my $d = $self->data;
        return keys %{$d->{planets}};
    }

    __PACKAGE__->meta->make_immutable;
    no Moose;
    1;
}


BEGIN {
    package API::ServerStatus;
    use Moose;

    use Carp qw(croak);
    use API::Object;

    with 'API::Object';


    sub path { "status/server" }
    sub expiration { minutes => 30 }

    __PACKAGE__->meta->make_immutable;
    no Moose;
    1;
}

1;
