package Paws::Net::ImplementationCaller::SSUser {
  use Moose;
  has UserName => (is => 'ro', isa => 'Str', default => sub { $ENV{USER} });
}
package Paws::Net::ImplementationCaller::SecretStore {
  use Moose;
  extends 'Paws::Net::ImplementationCaller::PASLoader';

  has '+api' => (default => sub { 'SecretStore' });

  sub get_user {
    return Paws::Net::ImplementationCaller::SSUser->new;
  }
}
1;
