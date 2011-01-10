package API::Error;
use Moose;
use Throwable;

with 'Throwable';

our $VERSION = '0.01';
use overload '""' => \&_stringify;

has message => ( 
    is => 'ro',
    isa => 'Str',
);

has code => ( 
    is => 'ro',
    isa => 'Int',
);

has data => ( 
    is => 'ro',
    isa => 'Undef|Item',
);

sub _stringify {
    my $self = shift;

    my $msg  = $self->message;
    my $code = $self->code;

    return "Error ${code}: $msg";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
