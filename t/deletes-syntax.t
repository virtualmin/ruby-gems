use Test::Strict tests => 3;                      # last test to print

syntax_ok( 'deletes.cgi' );
strict_ok( 'deletes.cgi' );
warnings_ok( 'deletes.cgi' );
