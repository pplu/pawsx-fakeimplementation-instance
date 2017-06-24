#!/usr/bin/env perl

use lib 't/fake-sqs-lib/';
use lib 't/fake-ec2-lib/';
use lib 't/lib/';

use Test::More;

use Paws;
use Paws::Net::ImplementationCaller;
use Paws::Net::ImplementationCaller::SQS;

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::ImplementationCaller->new(
      implementations => {
        SQS => Paws::Net::ImplementationCaller::SQS->new(
          extra_attributes_for_call => { injectable => 'mydomain' },
        ),
      },
    )
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result = $sqs->CreateQueue(QueueName => 'MyQueue');
cmp_ok($result->QueueUrl, 'eq', 'http://mydomain/queues/MyQueue', 'Got a QueueUrl');

$result = $sqs->DeleteQueue(QueueUrl => $result->QueueUrl);
isa_ok($result, 'Paws::API::Response');

done_testing;
