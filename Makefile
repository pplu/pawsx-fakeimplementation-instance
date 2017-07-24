test:
	carton exec -- prove -v -I lib t/
readme:
	carton exec perl -MPod::Markdown -e 'Pod::Markdown->new->filter(@ARGV)' lib/PawsX/FakeImplementation/Instance.pm > README.md

dist: readme
	carton exec dzil smoke
	carton exec dzil build
