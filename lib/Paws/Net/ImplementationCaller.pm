package Paws::Net::ImplementationCaller;
  use Moose;
  with 'Paws::Net::RetryCallerRole', 'Paws::Net::CallerRole';
  use Module::Runtime qw/require_module/;

  has implementations => (is => 'ro', isa => 'HashRef', default => sub { { } });
  has undef_implementations => (is => 'ro', isa => 'Str', default => 'load');

  sub get_implementation {
    my ($self, $service) = @_;
    return $self->implementations->{ $service } if (defined $self->implementations->{ $service });

    if ($self->undef_implementations eq 'die') {
      die "No implementation for $service";
    } elsif ($self->undef_implementations eq 'load') {
      my $class = "Paws::Net::ImplementationCaller::$service";
      require_module($class);

      $self->implementations->{ $service } = $class->new;
      return $self->implementations->{ $service };
    } else {
      die "Don't know what to do with undef_implementations value of " . $self->undef_implementations;
    }
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
