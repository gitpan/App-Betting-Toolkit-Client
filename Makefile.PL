use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Betting::Toolkit::Client',
    AUTHOR              => q{Paul G Webster <daemon@cpan.org>},
    VERSION_FROM        => 'lib/App/Betting/Toolkit/Client.pm',
    ABSTRACT_FROM       => 'lib/App/Betting/Toolkit/Client.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'bsd')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-Betting-Toolkit-Client-*' },
);
