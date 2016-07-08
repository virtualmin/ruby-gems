use Test::Strict tests => 3;                      # last test to print

syntax_ok( 'ruby-gems-lib.pl' );
strict_ok( 'ruby-gems-lib.pl' );
warnings_ok( 'ruby-gems-lib.pl' );
