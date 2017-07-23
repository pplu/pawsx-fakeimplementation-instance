package Paws::Net::ImplementationCaller::PASDefaultLogger {
  use Moose; 
  use v5.10; 
 
  sub trace { my ($self, $message) = @_; } 
  sub debug { my ($self, $message) = @_; } 
  sub info  { my ($self, $message) = @_; say $message } 
  sub warn  { my ($self, $message) = @_; say $message } 
  sub error { my ($self, $message) = @_; say $message } 
  sub fatal { my ($self, $message) = @_; say $message } 
 
  __PACKAGE__->meta->make_immutable; 

}
package Paws::Net::ImplementationCaller::PASLoader {
  use Moose;
  use Paws;
  use Paws::API::Response;
  use UUID qw/uuid/;

  has logger => (
    is => 'ro',
    lazy => 1,
    default => sub { Paws::Net::ImplementationCaller::PASDefaultLogger->new }
  );

  has api => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    trigger => \&api_set,
  );

  sub api_set {
    my $self = shift;
    Paws->preload_service($self->api);
  }

  has api_class => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
      return "Paws::" . shift->api;
    }
  );

  has extra_attributes_for_call => (
    is => 'ro',
    isa => 'HashRef',
  );

  sub get_user {
    my $self = shift;
    die "Please implement get_user"; 
  }

  sub do_call {
    my ($self, $service, $call_obj) = @_;

    my $uuid = uuid();

    my %extra_atts = %{ $self->extra_attributes_for_call } if (defined $self->extra_attributes_for_call);

    my $imp_class = $self->implementation_class_for($call_obj);
    my $instance = $imp_class->new(
      request_id => $uuid,
      params => $call_obj,
      returns_a => $call_obj->_returns,
      log => $self->logger,
      api_region => $service->_region_for_signature,
      api_method => $call_obj->_api_call,
      user => $self->get_user,
      service => $service->service,
      origin => '127.0.0.1',
      %extra_atts
    );

    my $return = eval { $instance->process };
    if ($@) {
      if (ref($@)) {
        if ($@->isa('Paws::API::Server::Exception')){
          $return = Paws::Exception->new(message => $@->message, code => $@->code, request_id => $uuid);
        } else {
          $return = Paws::Exception->new(message => "$@", code => 'InternalError', request_id => $uuid); 
        }
      } else {
        $return = Paws::Exception->new(message => "$@", code => 'InternalError', request_id => $uuid);
      }
    }
    if (not defined $call_obj->_returns or $call_obj->_returns eq 'Paws::API::Response') {
      return Paws::API::Response->new(request_id => $uuid);
    } else {
      return $return;
    }
  }

  sub implementation_class_for {
    my ($self, $call_object) = @_;

    my $class = $call_object->meta->name;
    $class =~ s/(::\w+)$/::Implementation$1/;

    Paws->load_class($class);

    return $class;
  }

}
1;
