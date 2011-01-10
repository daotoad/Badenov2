package API::Session;
use Moose;

with "API::Object";

sub path { 'session' }
sub expiration { hours => 1, minutes => 45 }

sub session_id {
    my $self = shift;
    my $d = $self->data // {};
    $d->{id};
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;
