package Client;

use Moose;
use MooseX::Storage;
use Try::Tiny;
use LWP::UserAgent;
use Crypt::SSLeay ();
use JSON::XS;
use IO::File;
use DateTime;
use File::Path qw(make_path);


use API::Error;
use API::Session;
use API::Body;
use API::Status;
use API::Star;

has [qw( 
    api_key
    server
    empire_name
    password 
    cache_dir 
    uri_scheme
)] => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has user_agent => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
);


sub load {
    my $class = shift;
    my $conf  = shift;

    my $fh = IO::File->new($conf, '<')
        or Client::Error::Cache->throw({action => 'read', file=> $conf, error => $!});

    warn "Opened file $fh\n";

    my $ser = join '', $fh->getlines;
    warn "Got $ser\n";
    my $data;
    try{ $data = $class->deserialize( $ser ) }
    catch{ Client::Error::Cache->throw({action => 'decode', file=> $conf, error => $_}) };

    die "Unknown error reading data\n" unless $data;

    return $class->new( %$data );
}

sub _build_user_agent { return LWP::UserAgent->new; }

sub get_session_id {
    my $self = shift;

    my $s = API::Session->load( $self );

    return $s->session_id
        if $s;

    my $result = $self->api_call( 
        empire => login => 
        $self->empire_name, $self->password, $self->api_key 
    );


    return $result->{result}{session_id};
}

sub serializer { return JSON::XS->new; }
sub serialize {
    my $self = shift;
    my $data = shift;

    my $j = $self->serializer;
    my $ser = $j->encode( $data );

    return $ser; 
}

sub deserialize {
    my $self = shift;
    my $ser = shift;

    warn "About to die\n";
    my $j = $self->serializer;

    warn "Unpacking with $j";
    
    my $data = $j->decode( $ser );

    return $data;
}

sub uri {
    my $self = shift;
    my $api  = shift;

    my $uri = sprintf "%s://%s/%s", $self->uri_scheme, $self->server, $api;
}

sub api_call {
    my $self   = shift;
    my $api    = shift;
    my $method = shift;
    my @params = @_;

    my $message = { jsonrpc => "2.0", id => 1, method => $method, params => [ @params ] };

    my $url = $self->uri($api);
    warn "Calling $api.$method [@params] at $url\n";

    my $response = $self->user_agent->post(
        $self->uri( $api ),
        Content => encode_json($message)
    );


    use Data::Dumper;
    warn Dumper $response;
    my $result = decode_json($response->content);

    use Data::Dumper;
    warn Dumper $result;
    API::Error->throw( $result->{error} )
        if exists $result->{error};

    warn "API Call Status updates\n";
    API::Session->cache( $self, { id => $self->get_session_id } )
        if $method ne 'login';
    API::EmpireStatus->cache( $self, $result->{result}{status}{empire} )
        if $result->{result}{status}{empire};

    API::ServerStatus->cache( $self, $result->{result}{status}{server} )
        if $result->{result}{status}{server};

    API::BodyStatus->cache( $self, $result->{result}{status}{body}{id}, $result->{result}{status}{body} )
        if $result->{result}{status}{body};

    return $result;
}

sub write_cache {
    my $self     = shift;
    my $data     = shift;
    my $filepath = shift;

    warn "write_cache $filepath for " . (caller(1))[3];

    my @dirpath =  split /\//, $filepath;
    pop @dirpath;
    my $dirpath = join '/', @dirpath; 
    
    warn "Making $dirpath";
    make_path( $dirpath );

    my $ser = $self->serialize($data);
    my $fh = IO::File->new( $filepath, '>' )
        or Client::Error::Cache->throw({action => 'write', file=> $filepath, error => $!});

    $fh->print( $ser );

    warn "wrote $ser\n";

    return;
}

sub read_cache {
    my $self     = shift;
    my $filepath = shift;

    warn "Reading $filepath for " . (caller(1))[3];

    return unless -e $filepath;

    my $fh = IO::File->new( $filepath, '<' )
        or Client::Error::Cache->throw({action => 'read', file=> $filepath, error => $!});

    my $ser = join '', $fh->getlines;

    my $data = try{ $self->deserialize($ser) } 
       or Client::Error::Cache->throw({action => 'decode', file=> $filepath, error => "$_"});

    return $data;
}

sub tag_data {
    my $self = shift;
    my $data = shift;
    my @expires = @_;

    my $n = DateTime->now( time_zone => 'UTC' );
    my $expires = $n->add( minutes => 30 );

    my $tagged = { expires => $expires->epoch, data => $data };

    return $tagged;
}



sub cache_data {
    my $self = shift;
    my $data = shift;
    my $path = shift;
    my @cache_expires = @_;

    warn "cache_data $path for " . (caller(1))[3];

    my $cachedir = $self->cache_dir;
    $path = "$cachedir/$path";

    $self->write_cache( $self->tag_data($data, @cache_expires), $path );

    return;
}

sub load_data {
    my $self = shift;
    my $path = shift;

    warn "load_data $path for " . (caller(1))[3];

    my $cachedir = $self->cache_dir;
    $path = "$cachedir/$path";

    my $tagged = $self->read_cache( $path );

    return unless $tagged;

    return unless $tagged->{data} && $tagged->{expires};

    return unless $tagged->{expires} > time();

    return $tagged->{data};
}



sub get_building_status {
    my $self   = shift;
    my $bdg_id = shift;

    my $bs = API::BuildingStatus->load( $self, $bdg_id );
}

sub get_body_status {
    my $self = shift;
    my $body_id = shift;

    my $bs = API::BodyStatus->load( $self, $body_id );
    return $bs if $bs;

    my $result = $self->api_call( 'body', get_status => $self->get_session_id, $body_id );

    $bs = API::BodyStatus->cache( $self, $body_id, $result->{result}{body} );
    API::EmpireStatus->cache( $self, $result->{result}{empire} );
    API::ServerStatus->cache( $self, $result->{result}{server} );

    return $bs;
}

sub get_empire_status {
    my $self = shift;

    my $session_id = $self->get_session_id;

    my $es = API::EmpireStatus->load( $self );

    warn "Got ES from cache" if $es;

    return $es if $es;

    my $result = $self->api_call( 'empire', get_status => $session_id );

    warn "$result->{result}{empire} and $result->{result}{server}";

    $es = API::EmpireStatus->cache( $self, $result->{result}{empire} )
        if $result->{result}{empire};

    API::ServerStatus->cache( $self, $result->{result}{server} )
        if $result->{result}{server};

    return $es;
}

sub get_server_status {
    my $self = shift;

    my $ss = API::ServerStatus->load( $self );

    return $ss if $ss;

    my $result = $self->api_call( 'empire', get_status => $self->get_session_id );

    API::EmpireStatus->cache( $self, $result->{result}{empire} )
        if $result->{result}{empire};

    $ss = API::ServerStatus->cache( $self, $result->{result}{server} )
        if $result->{result}{server};


    return $ss;
}

sub get_star {
    my $self = shift;
    my $id = shift;

    my $s = API::Star->load( $self, $id );
    return $s if $s;

    my $result = $self->api_call( 'map', get_star => $self->get_session_id, $id );

    $result->{result}{star}{id} = $id;

    API::BodyStatus->cache( $self, $_->{id}, $_ ), $_ = $_->{id}
        for @{$result->{result}{star}{bodies}};

    $s = API::Star->cache( $self, $id, $result->{result}{star} );

    return $s;
}


# look up building ids in cache for body.
# then get building data from cached files.
sub get_body_buildings {
    my $self = shift;
    my $body_id = shift;

    warn "get_body_buildings - $body_id\n";
    my $bb = API::BodyBuildings->load( $self, $body_id );
    warn "Got $bb\n" if $bb;
    return $bb if $bb;

    warn "Loading BodyBuildings\n";
    my $result = $self->api_call( 'body', get_buildings => $self->get_session_id, $body_id );

    my %buildings = %{ $result->{result}{buildings} };

    my $data = { id => $body_id, buildings => [ keys %buildings ] };
    $bb = API::BodyBuildings->cache( $self, $body_id, $data );

    
    for my $bdg ( keys %buildings ) {
        my $b_data = $buildings{$bdg};
        $b_data->{id}      = $bdg;
        $b_data->{body_id} = $body_id;
        my $bs = API::BuildingStatus->cache( $self, $bdg, $b_data );
    }

    return $bb;
}


BEGIN {
    package Client::Error;

    use Moose;
    use Throwable;

    with 'Throwable';

    has 'message' => (
        is => 'ro',
        isa => 'Str',
        required => 1,
    );

    sub _stringify {
        my $self = shift;

        return $self->message;
    }
}

BEGIN {
    package Client::Error::Cache;

    use Moose;
    use Throwable;
    use Scalar::Util qw(refaddr);

    with 'Throwable';
    use overload '""' => \&_stringify;

    has 'action' => (
        is => 'ro',
        isa => 'Str',
        required => 1,
    );

    has 'file' => (
        is => 'ro',
        isa => 'Str',
        required => 1,
    );

    has 'error' => (
        is => 'ro',
        isa => 'Str',
    );

    sub _stringify {
        my $self = shift;

        my $action = $self->action;
        my $file   = $self->file;
        my $error  = $self->error;

        my $prev = $self->previous_exception || '';
        $prev .= "\n" if $prev and refaddr $prev ne refaddr $self and $prev !~ /\n^/s;

        return "Cache error: unable to $action file $file - $error\n", ;
    }
}

1;
