readme:
	carton exec perl -MPod::Markdown -e 'Pod::Markdown->new->filter(@ARGV)' lib/Paws/Net/MultiplexCaller.pm > README.md

dist: readme
	carton exec dzil smoke
	carton exec dzil build
