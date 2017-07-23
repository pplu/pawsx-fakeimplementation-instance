#!/usr/bin/env perl

use lib 't/fake-sqs-lib/';
use lib 't/fake-ec2-lib/';
use lib 't/lib/';

use Test::More tests => 1;

use Paws;
use Paws::Net::MultiplexCaller;
use Paws::Net::ImplementationCaller::SQS;

package Paws::Net::TestCaller {
  use Moose;
  with 'Paws::Net::CallerRole';
  use Test::More;
  sub do_call {
    ok(1, 'Test Caller got called');
  }
  sub caller_to_response { }
}

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::MultiplexCaller->new(
      caller_for => { },
      default_caller => Paws::Net::TestCaller->new 
    )
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result = $sqs->CreateQueue(QueueName => 'qname');

# done testing. the do_call that has the test case should be called

done_testing;
