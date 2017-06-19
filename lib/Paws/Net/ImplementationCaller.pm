package Paws::Net::ImplementationCaller;
  use Moose;
  with 'Paws::Net::RetryCallerRole', 'Paws::Net::CallerRole';
  use Module::Runtime qw/require_module/;

  has _implementations => (is => 'ro', isa => 'HashRef', default => sub { { } });

  sub get_implementation {
    my ($self, $service) = @_;
    return $self->_implementations->{ $service } if (defined $self->_implementations->{ $service });

    my $class = "Paws::Net::ImplementationCaller::$service";
    require_module($class);

    $self->_implementations->{ $service } = $class->new;
    return $self->_implementations->{ $service };
  }

  sub send_request {
    my ($self, $service, $call_object) = @_;
    return (200, '', {});
  }

  sub caller_to_response {
    my ($self, $service, $call_object, $status, $content, $headers) = @_;

    my ($svc_name) = ($call_object->meta->name =~ m/Paws::(\w+)::/);

    my $imp_class = $self->get_implementation($svc_name);
    return $imp_class->invoke($service, $call_object);
  }

1;
