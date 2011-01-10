BEGIN {
    package API::Object;
    use Moose::Role;


    use Scalar::Util qw(blessed);
    use Carp qw(croak);
    our @CARP_NOT = qw(
        Class::MOP::Method::Wrapped
    );


    requires qw( path expiration );

    has data => (
        is  => 'rw',
        isa => 'Item',
    );

    sub load {
        my $class  = shift;
        my $client = shift;

        my $self = blessed $class ? $class : undef;

        my $path = $self  ? $self->path
                 : $class ? $class->path(@_)
                 : undef;

        croak "Unable to get cache path for $class"
            unless defined $path;

        my $data = $client->load_data( $path );

        return unless $data;

        $self = $class->new()
            unless $self;

        $self->data( $data );

        return $self;
    }


    sub cache {
        my $class  = shift;
        my $client = shift;
        my $data   = shift;

        my $self = blessed $class ? $class
                 : $class->new( data => $data );
        
        $client->cache_data( $self->data, $self->path, $self->expiration );
        return $self;
    }


    no Moose::Role;
}

BEGIN {
    package API::ObjectWithID;
    use Moose::Role;

    with 'API::Object';
    requires 'id_key';

    use Carp qw(croak);
    our @CARP_NOT = qw(
        Class::MOP::Method::Wrapped
    );


    sub id {
        my $self = shift;

        my $d = $self->data;
        my $key = $self->id_key;
        my $id = $d->{$key};

        return $id;
    }

    around path => sub {
        my $orig  = shift;
        my $class = shift;

        my $self = $class if blessed $class;

        my $id = @_    ? shift
               : $self ? $self->id
               : undef;

        croak(
            $self ? "No id for $self"
            : "Must supply an object id when calling path as a class method"
        ) unless $id;

        return $orig->($class, $id);
    };

    around cache => sub {
        my $orig   = shift;
        my $class  = shift;
        my $client = shift;

        my $self = $class if blessed $class;

        my $id = @_    ? shift
               : $self ? $self->id
               : undef;

        croak(
            $self ? "No id for $self"
            : "Must supply an object id when calling cache as a class method"
        ) unless $id;


        return $orig->($class, $client, @_);
    };

    around load => sub {
        my $orig   = shift;
        my $class  = shift;
        my $client = shift;

        my $self = $class if blessed $class;

        my $id = @_    ? shift
               : $self ? $self->id
               : undef;

        croak(
            $self ? "No id for $self"
            : "Must supply an object id when calling load as a class method"
        ) unless $id;

        return $orig->($class, $client, $id);
    };

    no Moose::Role;
}



1;
