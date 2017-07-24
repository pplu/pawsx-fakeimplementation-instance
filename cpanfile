requires 'Paws';
requires 'UUID';

on test => sub {
  requires 'Paws::Net::MultiplexCaller';
  requires 'Paws::Kinesis::MemoryCaller';
  requires 'Test::More';
  requires 'Test::Exception';

  requires 'Pod::Markdown';

  requires 'Dist::Zilla';
  requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
  requires 'Dist::Zilla::Plugin::VersionFromModule';
  requires 'Dist::Zilla::PluginBundle::Git';
};
