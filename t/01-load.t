#! /usr/bin/perl

use strict;
use warnings;

use Test::More;

use_ok('Paws::Net::MultiplexCaller');
use_ok('Paws::Net::ImplementationCaller::PASLoader');
use_ok('Paws::Net::ImplementationCaller::InstanceLoader');

done_testing;
