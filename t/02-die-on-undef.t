#!/usr/bin/env perl

use lib 't/fake-sqs-lib/';
use lib 't/lib/';

use Test::More;
use Test::Exception;

use Paws;
use Paws::Net::ImplementationCaller;
use Paws::Net::ImplementationCaller::SQS;

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::ImplementationCaller->new(
      implementations => {
        'SQS' => Paws::Net::ImplementationCaller::SQS->new(
          user => undef,
        ),
      },
      undef_implementations => 'die',
    )
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result;
lives_ok(sub {
  $result = $sqs->CreateQueue(QueueName => 'qname');
}, 'SQS is auto-loaded');

my $ec2 = $paws1->service('EC2', region => 'test');
throws_ok(sub {
  $result = $ec2->AllocateAddress;
}, qr/^No implementation for EC2/, "Call to AllocateAddress on EC2 dies (won't load an EC2 implementation)");

done_testing;
