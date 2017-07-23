package Paws::Net::ImplementationCaller::InstanceLoader {
  use Moose;
  use Paws;
  use UUID qw/uuid/;

  has api_class => (
    is => 'ro',
    isa => 'Str',
    required => 1,
  );

  has instance => (
    is => 'ro',
    lazy => 1,
    default => sub {
      my $self = shift;
      Paws->load_class($self->api_class);
      return $self->api_class->new;
    }
  );

  sub do_call {
    my ($self, $service, $call_obj) = @_;

    my $uuid = uuid;

    my ($method_name) = ($call_obj->meta->name =~ m/^Paws::.*?::(.*)$/);

    my $return = eval { $self->instance->$method_name($call_obj) };
    if ($@) {
      if (ref($@)) {
        if ($@->isa('Paws::Exception')){
          $return = $@;
        } else {
          $return = Paws::Exception->new(message => "$@", code => 'InternalError', request_id => $uuid); 
        }
      } else {
        $return = Paws::Exception->new(message => "$@", code => 'InternalError', request_id => $uuid);
      }
    } else {
      if (not defined $call_obj->_returns or $call_obj->_returns eq 'Paws::API::Response') {
        $return = Paws::API::Response->new(request_id => $uuid);
      } else {
        $return = $self->new_with_coercions($call_obj->_returns, %$return);
      }
    }
    return $return;
  }

  sub new_with_coercions {
    my ($self, $class, %params) = @_;

    Paws->load_class($class);
    my %p;

    if ($class->does('Paws::API::StrToObjMapParser')) {
      my ($subtype) = ($class->meta->find_attribute_by_name('Map')->type_constraint =~ m/^HashRef\[(.*?)\]$/);
      if (my ($array_of) = ($subtype =~ m/^ArrayRef\[(.*?)\]$/)){
        $p{ Map } = { map { $_ => [ map { $self->new_with_coercions("$array_of", %$_) } @{ $params{ $_ } } ] } keys %params };
      } else {
        $p{ Map } = { map { $_ => $self->new_with_coercions("$subtype", %{ $params{ $_ } }) } keys %params };
      }
    } elsif ($class->does('Paws::API::StrToNativeMapParser')) {
      $p{ Map } = { %params };
    } else {
      foreach my $att (keys %params){
        my $att_meta = $class->meta->find_attribute_by_name($att);
  
        Moose->throw_error("$class doesn't have an $att") if (not defined $att_meta);
        my $type = $att_meta->type_constraint;
  
        if ($type eq 'Bool') {
          $p{ $att } = ($params{ $att } == 1)?1:0;
        } elsif ($type eq 'Str' or $type eq 'Num' or $type eq 'Int') {
          $p{ $att } = $params{ $att };
        } elsif ($type =~ m/^ArrayRef\[(.*?)\]$/){
          my $subtype = "$1";
          if ($subtype eq 'Str' or $subtype eq 'Str|Undef' or $subtype eq 'Num' or $subtype eq 'Int' or $subtype eq 'Bool') {
            $p{ $att } = $params{ $att };
          } else {
            $p{ $att } = [ map { $self->new_with_coercions("$subtype", %{ $_ }) } @{ $params{ $att } } ];
          }
        } elsif ($type->isa('Moose::Meta::TypeConstraint::Enum')){
          $p{ $att } = $params{ $att };
        } else {
          $p{ $att } = $self->new_with_coercions("$type", %{ $params{ $att } });
        }
      }
    }
    return $class->new(%p);
  }


}
1;
