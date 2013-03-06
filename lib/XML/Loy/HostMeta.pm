package XML::Loy::HostMeta;
use XML::Loy with => (
  prefix => 'hm',
  namespace => 'http://host-meta.net/xrd/1.0'
);

use Carp qw/carp/;

# No constructor
sub new {
  carp 'Only use ' . __PACKAGE__ . ' as an extension to XRD';
  return;
};

# host information
sub host {
  my $self = shift;

  unless ($_[0]) {
    my $h = $self->at('Host') or return;
    return $h->all_text;
  };

  # Set hist information
  return $self->set(Host => shift);
};


1;


__END__

=pod

=head1 NAME

XML::Loy::Hostmeta - Extend XML::Loy::XRD for use with HostMeta


=head1 SYNOPSIS

  use XML::Loy::XRD;

  my $xrd = XML::Loy::XRD->new;
  $xrd->extension('XML::Loy::HostMeta');

  $xrd->subject('http://sojolicio.us/');
  $xrd->host('sojolicio.us');

  print $xrd->to_pretty_xml;

  # <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  # <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"
  #      xmlns:hm="http://host-meta.net/xrd/1.0"
  #      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  #   <Subject>http://sojolicio.us/</Subject>
  #   <hm:Host>sojolicio.us</hm:Host>
  # </XRD>


=head1 DESCRIPTION

L<XML::Loy::HostMeta> is an extension
to L<XML::Loy::XRD> and provides addititional
functionality for the work with
L<HostMeta|http://tools.ietf.org/html/draft-hammer-hostmeta>
documents.


=head1 METHODS

=head2 host

  $xrd->host('sojolicio.us');
  print $xrd->host;

Host information of the xrd.


=head1 DEPENDENCIES

L<Mojolicious>.


=head1 AVAILABILITY

  https://github.com/Akron/XML-Loy


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2013, L<Nils Diewald|http://nils-diewald.de/>.

This program is free software, you can redistribute it
and/or modify it under the same terms as Perl.

=cut