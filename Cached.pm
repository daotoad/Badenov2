package Cached;

use Moose::Role;
use MooseX::Storage;
use File::Path ();
use File::Spec ();
use Try::Tiny;
use DateTime ();

with Storage('format' => 'JSON', 'io' => 'File');

has 'dl_time' => (
    is => 'rw',
    isa => 'Int',
    default => sub { time() },
);

requires qw( expiration_hours expiration_minutes expiration_seconds );

sub expiration {
    my $self = shift;

    my $expires = $self->last_update->add(
        hours   => $self->expiration_hours,
        minutes => $self->expiration_minutes,
        seconds => $self->expiration_seconds,
    );

    return $expires;
}

sub expired {
    my $self = shift;
    my $n = DateTime->now;  my $e = $self->expiration;
    my $s = $n >= $e ? 'EXPIRED' : 'OK';
    warn "$self expired? $n / $e : $s\n";
    return DateTime->now >= $self->expiration;
}

sub register_update {
    my $self = shift;
    return $self->last_update( DateTime->now );
}

sub last_update {
    my $self = shift;

    if( @_) {
        my $d = shift;
        $self->dl_time( $d->epoch );
    }

    my $dt = DateTime->from_epoch( epoch => $self->dl_time );

    return $dt;
}


before store => sub { warn "STORE @_\n";  };

sub _get_cache_file {
    my $class = shift;
    my %arg   = @_;

    for( qw[cache_dir cache_file cache_path] ) {
        next if defined $arg{$_};

        $arg{$_} = try { $class->$_ };

        Carp::croak "required argument '$_' missing in restore"
            unless defined $arg{$_};
    }

    my $dir  = File::Spec->catdir( $arg{cache_dir}, @{$arg{cache_path}} );
    my $file = File::Spec->catfile( $dir, $arg{cache_file} );

    File::Path::mkpath( $dir ) unless -d $dir;

    return $file;
}

sub restore {
    my $class = shift;
    my %arg   = @_;

    my $file = $class->_get_cache_file(%arg);
    my $o = try { $class->load( $file ) };

    warn "Loaded $class $o\n";

    return $o if defined $o and not $o->expired;

    return;
}

sub update {
    my $class = shift;
    my $data = shift;
    my %arg   = @_;

    warn "Updating $class\n";
    use Data::Dumper;
    warn Dumper $data;

    my $file = $class->_get_cache_file(%arg);

    my $s = $class->new( %$data );

    Carp::croak "Error creating $class object" unless $s;

    $s->store( $file );

    return $s;
}


no Moose::Role;
1;
