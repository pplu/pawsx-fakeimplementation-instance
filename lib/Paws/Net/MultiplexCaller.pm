package Paws::Net::MultiplexCaller;
  use Moose;
  with 'Paws::Net::CallerRole';

  # TODO: HashRef of things that do Paws::Net::CallerRole
  has caller_for => (is => 'ro', isa => 'HashRef', required => 1);
  # TODO: thing that does Paws::Net::CallerRole or Undef
  has default_caller => (is => 'ro', isa => 'Object');

  sub get_implementation {
    my ($self, $service) = @_;
    return $self->caller_for->{ $service } if (defined $self->caller_for->{ $service });
    return $self->default_caller if (defined $self->default_caller);
    die "Can't find a caller for $service";
  }

  sub do_call {
    my ($self, $service, $call_object) = @_;
    my $result = $self->get_implementation($self->service_from_callobject($call_object))
             ->do_call($service, $call_object);

    if ($result->isa('Paws::Exception')){
      $result->throw;
    }

    return $result;
  }

  sub caller_to_response {
    #my ($self, $service, $call_object, $status, $content, $headers) = @_;
    die "Die caller_to_response is not needed on the Multiplex caller";
  }

  sub service_from_callobject {
    my ($self, $call_object) = @_;
    my ($svc_name) = ($call_object->meta->name =~ m/^Paws::(\w+)::/);
    die "$call_object doesn't seem to be a Paws::SERVICE::CALL" if (not defined $svc_name);
    return $svc_name;
  }

1;
