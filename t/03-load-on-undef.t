#!/usr/bin/env perl

use lib 't/fake-sqs-lib/';
use lib 't/fake-ec2-lib/';
use lib 't/lib/';

use Test::More;
use Test::Exception;

use Paws;
use Paws::Net::ImplementationCaller;
use Paws::Net::ImplementationCaller::SQS;

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::ImplementationCaller->new(
#      implementations => {
#        'SQS' => Paws::Net::ImplementationCaller::SQS->new(
#          user => undef,
#        ),
#      },
      undef_implementations => 'load',
    )
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result;
lives_ok(sub {
  $result = $sqs->CreateQueue(QueueName => 'qname');
}, 'Can call DeleteQueue');

my $ec2 = $paws1->service('EC2', region => 'test');
lives_ok(sub {
  $result = $ec2->AllocateAddress;
}, "EC2 is auto-loaded");

done_testing;
