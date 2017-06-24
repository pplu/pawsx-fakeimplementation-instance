#!/usr/bin/env perl

use lib 't/fake-sqs-lib/';
use lib 't/fake-ec2-lib/';
use lib 't/lib/';

use Test::More;
use Test::Exception;

use Paws;
use Paws::Net::ImplementationCaller;

my $paws1 = Paws->new(
  config => {
    caller => Paws::Net::ImplementationCaller->new,
  }
);

my $sqs = $paws1->service('SQS', region => 'test');
my $result;
throws_ok(sub {
  $result = $sqs->CreateQueue(QueueName => '+UnstructuredException');
}, 'Paws::Exception', 'Code that uses die gets reported to consumer as Paws::Exception');
like($@->message, qr/Text of an unstructured exception/, 'the message in die is in the message of the exception');
cmp_ok($@->code, 'eq', 'InternalError', 'The Paws::Exception code is an Internal Error');

throws_ok(sub {
  $result = $sqs->CreateQueue(QueueName => '+StructuredException');
}, 'Paws::Exception', 'Code that uses structured exceptions gets reported to consumer as Paws::Exception');
like($@->message, qr/Text of a structured exception/);
cmp_ok($@->code, 'eq', 'InternalError', 'The Paws::Exception code is an Internal Error');

throws_ok(sub {
  $result = $sqs->CreateQueue(QueueName => '+InvalidName');
}, 'Paws::Exception', 'Code that uses Paws::API::Server::Exceptions gets reported to consumer as Paws::Exception');
cmp_ok($@->message, 'eq', 'My QueueName has invalid chars');
cmp_ok($@->code, 'eq', 'InvalidName', 'The Paws::Exception code is the same as PAS::Exception');



done_testing;
