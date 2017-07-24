#!/usr/bin/env perl

use lib 't/fake-sqs-inst/';

use Test::More;
use Test::Exception;

use Paws;
use Paws::Net::MultiplexCaller;
use PawsX::FakeImplementation::Instance;

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::MultiplexCaller->new(
      caller_for => {
        SQS => PawsX::FakeImplementation::Instance->new(
          api_class => 'FakeSQS',
          params => {
            url => 'http:/my.overwritten.url/queues/'
          }
        ),
      }
    ),
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result = $sqs->CreateQueue(QueueName => 'MyQueue');
cmp_ok($result->QueueUrl, 'eq', 'http:/my.overwritten.url/queues/MyQueue', 'Got a QueueUrl');

done_testing;
