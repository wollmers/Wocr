use strict;
use warnings;

use lib qw( ../lib );

use Wocr;
use Wocr::DB::Schema;
use Wocr::Command::setup;

use Mojo::JSON qw(decode_json encode_json);

use Test::More;
END { done_testing(); }

use Test::Mojo;

my $db = Wocr::DB::Schema->connect('dbi:SQLite:dbname=:memory:');

ok($db, 'DB schema connected');

Wocr::Command::setup->inject_sample_data($db,'test');

ok($db->resultset('Package')->search( { name => { -like => 'Wocr' . '%' }}), 'DB package exists');



my $t = Test::Mojo->new(Wocr->new(db => $db));
$t->ua->max_redirects(2);

subtest 'Static File' => sub {

  $t->get_ok('/robots.txt')->status_is(200);

};

subtest 'Static page' => sub {

  # landing page
  $t->get_ok('/')->status_is(200)->text_is(h2 => 'Testpage for Wocr');

  $t->get_ok('/front/index')->status_is(200)->text_is(h2 => 'Testpage for Wocr');


  # attempt to get non-existant page
  $t->get_ok('/page/doesntexist')->status_is(404);

};

