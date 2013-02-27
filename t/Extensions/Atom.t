#!/usr/bin/perl
use strict;
use warnings;

$|++;

use lib ('lib', '../lib', '../../lib', '../../../lib');

use Mojo::ByteStream 'b';
use Test::Mojo;
use Mojolicious::Lite;

use Test::More;

my $poco_ns  = 'http://www.w3.org/TR/2011/WD-contacts-api-20110616/';
my $xhtml_ns = 'http://www.w3.org/1999/xhtml';

use_ok('MojoX::XML::Atom');

# new
my $atom = MojoX::XML::Atom->new('feed');
is(ref($atom), 'MojoX::XML::Atom', 'new 1');

# New Text
# text
my $text = $atom->new_text('Hello World!');
is($text->at('text')->text, 'Hello World!', 'Text: text1');
$text = $atom->new_text(text => 'Hello World!');
is($text->at('text')->text, 'Hello World!', 'Text: text2');
$text = $atom->new_text(type => 'text',
			content => 'Hello World!');
is($text->at('text')->text, 'Hello World!', 'Text: text3');

# xhtml
$text = $atom->new_text(type => 'xhtml',
			content => 'Hello World!');

is($text->at('text')->text, '', 'Text: xhtml1');
is($text->at('text')->all_text, 'Hello World!', 'Text: xhtml2');
is($text->at('div')->namespace, $xhtml_ns, 'Text: xhtml3');


$text = $atom->new_text('xhtml' => 'Hello <strong>World</strong>!');
is($text->at('text')->text, '', 'Text: xhtml4');
is($text->at('text')->all_text, 'Hello World!', 'Text: xhtml5');
is($text->at('div')->namespace, $xhtml_ns, 'Text: xhtml6');

# html
$text = $atom->new_text(type => 'html',
			content => 'Hello <strong>World</strong>!');
is($text->at('text')->text,
   'Hello <strong>World</strong>!',
   'Text: html1'
    );
$text = $atom->new_text('html' => 'Hello <strong>World</strong>!');
is($text->at('text')->text,
   'Hello <strong>World</strong>!',
   'Text: html2'
    );

# New Person
my $person = $atom->new_person(name => 'Bender',
			       uri => 'http://sojolicio.us/bender');
is($person->at('name')->text, 'Bender', 'Person1');
is($person->at('uri')->text, 'http://sojolicio.us/bender', 'Person2');

# New Date
my $date = $atom->new_date('2011-07-30T16:30:00Z');
is($date, '2011-07-30T16:30:00Z', 'Date1');
is($date->epoch, 1312043400, 'Date2');
$date = $atom->new_date(1312043400);
is($date, '2011-07-30T16:30:00Z', 'Date3');
is($date->epoch, 1312043400, 'Date4');

# Add entry
ok(my $entry = $atom->entry(id => '#Test1'), 'Add entry with hash');
is($atom->at('entry > id')->text, '#Test1', 'Add entry 1');
$entry = $atom->entry(id => '#Test2');
is($atom->find('entry > id')->[0]->text, '#Test1', 'Add entry 2');
is($atom->find('entry > id')->[1]->text, '#Test2', 'Add entry 3');
is($atom->find('entry')->[0]->attrs('xml:id'), '#Test1', 'Add entry 4');
is($atom->find('entry')->[1]->attrs('xml:id'), '#Test2', 'Add entry 5');

# Add entry without id
ok($entry = $atom->entry(summary => 'Just fun'), 'Add entry without id');
ok($entry->add(id => '#Test3'), 'Add new entry');

is($atom->entry('#Test1')->at('id')->text, '#Test1', 'Get entry');
is($atom->entry('#Test2')->at('id')->text, '#Test2', 'Get entry');
is($atom->entry('#Test3')->at('id')->text, '#Test3', 'Get entry');
is($atom->entry('#Test3')->at('summary')->text, 'Just fun', 'Get entry');

# Add content
$entry = $atom->at('entry');

# diag $atom->to_pretty_xml;

ok($entry->content('Test content'), 'Add content');

is($atom->at('entry content')->text,
   'Test content',
   'Add content 1');

ok($entry->content('html' => '<p>Test content'), 'New content add');

is($atom->at('entry content[type=html]')->text,
   '<p>Test content',
   'Add content 2');

ok($entry->content('xhtml' => '<p>Test content</p>'), 'New content add');
is($atom->at('entry content[type="xhtml"]')->text,
   '',
   'Add content 3');
is($atom->at('entry content[type="xhtml"]')->all_text,
   'Test content',
   'Add content 4');
is($atom->at('entry content[type="xhtml"] div')->namespace,
   'http://www.w3.org/1999/xhtml',
   'Add content 5');

done_testing;
exit;







$atom->find('entry')
    ->[1]->add_content(type    => 'movie',
		       content => b('Test')->b64_encode);
is($atom->at('entry content[type="movie"]')->text,
    'VGVzdA==',
    'Add content 6');

# Add author
$atom->add_author(name => 'Fry');
is($atom->at('feed > author > name')->text,
   'Fry',
   'Add author 1');
$entry = $atom->at('entry');
$entry->add_author($person);
is($atom->at('feed > entry > author > name')->text,
   'Bender',
    'Add author 2');
is($atom->at('feed > entry > author > uri')->text,
   'http://sojolicio.us/bender',
    'Add author 3');


# Add category
$entry->add_category('world');
is($entry->at('category')->attrs('term'),
   'world',
   'Add category 1');
ok($entry->at('category[term]'),
   'Add category 2');


# Add contributor
$atom->add_contributor(name => 'Leela');
is($atom->at('feed > contributor > name')->text,
   'Leela',
   'Add contributor 1');
$entry = $atom->find('entry')->[1];
$entry->add_contributor($person);
is($atom->at('feed > entry > contributor > name')->text,
   'Bender',
    'Add contributor 2');
is($atom->at('feed > entry > contributor > uri')->text,
   'http://sojolicio.us/bender',
    'Add contributor 3');



# Add generator
$atom->add_generator('Sojolicious');
is($atom->at('generator')->text, 'Sojolicious', 'Add generator');


# Add icon
$entry->add_icon('http://sojolicio.us/favicon.ico');
is($atom->at('icon')->text, 'http://sojolicio.us/favicon.ico',
   'Add icon');


# Add id
$entry = $atom->add_entry;
$entry->add_id('#Test3');

is($atom->find('entry')->[2]->attrs('xml:id'), '#Test3', 'Add id 1');
is($atom->find('entry > id')->[2]->text, '#Test3', 'Add id 2');


# Add link
$entry->add_link('http://sojolicio.us/alternative');
is($entry->at('link')->text, '', 'Add link 1');
is($entry->at('link')->attrs('href'), 
   'http://sojolicio.us/alternative',
   'Add link 2');
is($entry->at('link')->attrs('rel'), 'related', 'Add link 3');
$entry->add_link(rel => 'self',
		 href => 'http://sojolicio.us/entry',
		 title => 'Self-Link');
is($entry->at('link[title]')->attrs('title'),
   'Self-Link',
   'Add link 4');


# Add logo
$entry->add_logo('http://sojolicio.us/logo.png');
is($atom->at('logo')->text, 'http://sojolicio.us/logo.png',
   'Add logo');


# Add published
$entry->add_published($date);
is($entry->at('published')->text,
   '2011-07-30T16:30:00Z',
   'Add published 1');
$atom->at('entry')->add_published(1314721000);
is($atom->at('entry published')->text,
   '2011-08-30T16:16:40Z',
   'Add published 2');


# Add rights
$atom->add_rights('Creative Commons');
is($atom->at('rights')->text,
   'Creative Commons',
   'Add rights 1');
$entry->add_rights('xhtml' => '<p>Creative Commons</p>');
is($entry->at('rights')->text,
   '',
   'Add rights 2');
is($entry->at('rights')->all_text,
   'Creative Commons',
   'Add rights 3');


# Add source
my $source = $entry->add_source('xml:base' =>
				'http://source.sojolicio.us/');
$source->add_author(name => 'Zoidberg');
is($atom->at('source > author > name')->text,
   'Zoidberg',
   'Add source');


# Add subtitle
$entry = $atom->at('entry');
$entry->add_subtitle('Test subtitle');
is($atom->at('entry subtitle')->text,
   'Test subtitle',
   'Add subtitle 1');

$entry->add_subtitle('html' => '<p>Test subtitle');
is($atom->at('entry subtitle[type="html"]')->text,
   '<p>Test subtitle',
   'Add subtitle 2');

$entry->add_subtitle('xhtml' => '<p>Test subtitle</p>');
is($atom->at('entry subtitle[type="xhtml"]')->text,
   '',
   'Add subtitle 3');
is($atom->at('entry subtitle[type="xhtml"]')->all_text,
   'Test subtitle',
   'Add subtitle 4');
is($atom->at('entry subtitle[type="xhtml"] div')->namespace,
   'http://www.w3.org/1999/xhtml',
   'Add subtitle 5');

$atom->find('entry')
    ->[1]->add_subtitle(type    => 'movie',
			content => b('Test')->b64_encode);
is($atom->at('entry subtitle[type="movie"]')->text,
    'VGVzdA==',
    'Add subtitle 6');

my $subtitle = $atom->new_text('Test subtitle 2');
ok($atom->add_subtitle($source), 'Add subtitle 7');


# Add summary
$entry = $atom->at('entry');
$entry->add_summary('Test summary');
is($atom->at('entry summary')->text,
   'Test summary',
   'Add summary 1');

$entry->add_summary('html' => '<p>Test summary');
is($atom->at('entry summary[type="html"]')->text,
   '<p>Test summary',
   'Add summary 2');

$entry->add_summary('xhtml' => '<p>Test summary</p>');
is($atom->at('entry summary[type="xhtml"]')->text,
   '',
   'Add summary 3');
is($atom->at('entry summary[type="xhtml"]')->all_text,
   'Test summary',
   'Add summary 4');
is($atom->at('entry summary[type="xhtml"] div')->namespace,
   'http://www.w3.org/1999/xhtml',
   'Add summary 5');

$atom->find('entry')
    ->[1]->add_summary(type    => 'movie',
			content => b('Test')->b64_encode);
is($atom->at('entry summary[type="movie"]')->text,
    'VGVzdA==',
    'Add summary 6');

my $summary = $atom->new_text('Test summary 2');
ok($atom->add_summary($source), 'Add summary 7');


# Add title
$entry = $atom->at('entry');
$entry->add_title('Test title');
is($atom->at('entry title')->text,
   'Test title',
   'Add title 1');

$entry->add_title('html' => '<p>Test title');
is($atom->at('entry title[type="html"]')->text,
   '<p>Test title',
   'Add title 2');

$entry->add_title('xhtml' => '<p>Test title</p>');
is($atom->at('entry title[type="xhtml"]')->text,
   '',
   'Add title 3');
is($atom->at('entry title[type="xhtml"]')->all_text,
   'Test title',
   'Add title 4');
is($atom->at('entry title[type="xhtml"] div')->namespace,
   'http://www.w3.org/1999/xhtml',
   'Add title 5');

$atom->find('entry')
    ->[1]->add_title(type    => 'movie',
			content => b('Test')->b64_encode);
is($atom->at('entry title[type="movie"]')->text,
    'VGVzdA==',
    'Add title 6');

my $title = $atom->new_text('Test title 2');
ok($atom->add_title($source), 'Add title 7');


# Add updated
$entry = $atom->find('entry')->[1];
$entry->add_updated($date);
is($entry->at('updated')->text,
   '2011-07-30T16:30:00Z',
   'Add updated 1');
$atom->at('entry')->add_updated(1314721000);
is($atom->at('entry updated')->text,
   '2011-08-30T16:16:40Z',
   'Add updated 2');



# Examples
$atom = MojoX::XML::Atom->new('entry');
$entry = $atom->add_entry(id => '#467r57');
$entry->add_author(name   => 'Bender');
$entry->add_content(text  => "I am Bender!");
$entry->add_content(html  => "I am <strong>Bender</strong>!");
$entry->add_content(xhtml => "I am <strong>Bender</strong>!");
$entry->add_content(movie => b("I am Bender!")->b64_encode);

is($atom->at('entry > author > name')->text, 'Bender', 'Text');
is($atom->at('content[type]')->text,  'I am Bender!', 'Text');
is($atom->at('content[type="html"]')->text,  'I am <strong>Bender</strong>!', 'Text');
is($atom->at('content[type="xhtml"]')->text,  '', 'Text');
is($atom->at('content[type="xhtml"] div')->text,  'I am!', 'Text');
is($atom->at('content[type="xhtml"] div')->all_text,  'I am Bender!', 'Text');
is($atom->at('content[type="movie"]')->text, 'SSBhbSBCZW5kZXIh', 'Text');

$atom = MojoX::XML::Atom->new(<<'ATOM');
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <id>#467r57</id>
    <author>
      <name>Bender</name>
    </author>
  </entry>
</feed>
ATOM

is($atom->at('entry > author > name')->text, 'Bender', 'Text');

$poco_ns = 'http://www.w3.org/TR/2011/WD-contacts-api-20110616/';

# Person constructs
$person = $atom->new_person('name' => 'Fry');
$person->add_namespace('poco' => $poco_ns);
$person->add('uri', 'http://sojolicio.us/fry');
$person->add('poco:birthday' => '1/1/1970');

is($person->at('person name')->text, 'Fry', 'Person-Name');
is($person->at('person uri')->text, 'http://sojolicio.us/fry', 'Person-URI');
is($person->at('person birthday')->text, '1/1/1970', 'Person-Poco-Birthday');
is($person->at('person birthday')->namespace, $poco_ns, 'Person-Poco-NS');

# Date consructs
$date = $atom->new_date(1313131313);
$atom->add_updated($date);
is($atom->at('updated')->text, '2011-08-12T06:41:53Z', 'Updated');
