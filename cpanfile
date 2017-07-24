requires 'Paws';

on test => sub {
  requires 'Paws::Kinesis::MemoryCaller';
  requires 'Test::More';
  requires 'Test::Exception';
};
