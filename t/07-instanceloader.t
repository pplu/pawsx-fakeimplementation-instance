#!/usr/bin/env perl

use lib 't/fake-sqs-inst/';

use Test::More;
use Test::Exception;

use Paws;
use Paws::Net::ImplementationCaller;
use Paws::Net::ImplementationCaller::InstanceLoader;

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::ImplementationCaller->new(
      implementations => {
        SQS => Paws::Net::ImplementationCaller::InstanceLoader->new(
          api_class => 'FakeSQS', 
        ),
      }
    ),
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result = $sqs->CreateQueue(QueueName => 'MyQueue');
cmp_ok($result->QueueUrl, 'eq', 'http://sqs.fake.amazonaws.com/123456789012/MyQueue', 'Got a QueueUrl');

my $qurl = $result->QueueUrl;

$result = $sqs->SendMessage(MessageBody => 'Message 1', QueueUrl => $qurl);
ok(defined($result->MessageId), 'Got a messageid for message 1');
$result = $sqs->SendMessage(MessageBody => 'Message 2', QueueUrl => $qurl);
ok(defined($result->MessageId), 'Got a messageid for message 2');

$result = $sqs->ReceiveMessage(QueueUrl => $qurl);
cmp_ok($result->Messages->[0]->Body, 'eq', 'Message 1', 'Got first message');

$result = $sqs->ReceiveMessage(QueueUrl => $qurl);
cmp_ok($result->Messages->[0]->Body, 'eq', 'Message 2', 'Got second message');

$result = $sqs->DeleteQueue(QueueUrl => $qurl);
isa_ok($result, 'Paws::API::Response');

throws_ok(sub {
  $result = $sqs->SendMessage(MessageBody => 'Message 1', QueueUrl => $qurl);
}, 'Paws::Exception');

done_testing;