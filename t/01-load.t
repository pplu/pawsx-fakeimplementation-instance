#! /usr/bin/perl

use strict;
use warnings;

use Test::More;

use_ok('Paws::Net::ImplementationCaller');
TODO: {
  local $TODO = 'Not yet ready';

  use_ok('Paws::Net::ImplementationCaller::PASLoader');
  use_ok('Paws::Net::ImplementationCaller::InstanceLoader');
};

done_testing;
