use strict;
use warnings;
package Dist::Zilla::Plugin::Keywords;
BEGIN {
  $Dist::Zilla::Plugin::Keywords::AUTHORITY = 'cpan:ETHER';
}
# git description: 38529b9
$Dist::Zilla::Plugin::Keywords::VERSION = '0.001';
# ABSTRACT: add keywords to metadata in your distribution
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
with 'Dist::Zilla::Role::MetaProvider';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose 'ArrayRef';
use MooseX::Types::Common::String 'NonEmptySimpleStr';
use namespace::autoclean;

my $word = subtype NonEmptySimpleStr,
    where { !/\s/ };

my $wordlist = subtype ArrayRef[$word];
coerce $wordlist, from ArrayRef[NonEmptySimpleStr],
    via { [ map { split /\s+/, $_ } @$_ ] };


sub mvp_aliases { +{ keyword => 'keywords' } }
sub mvp_multivalue_args { qw(keywords) }

has keywords => (
    is => 'ro', isa => $wordlist,
    coerce => 1,
    default => sub { [] },
);

sub metadata
{
    my $self = shift;
    return { keywords => $self->keywords };
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=encoding UTF-8

=for :stopwords Karen Etheridge irc

=head1 NAME

Dist::Zilla::Plugin::Keywords - add keywords to metadata in your distribution

=head1 VERSION

version 0.001

=head1 SYNOPSIS

In your F<dist.ini>:

    [Keywords]
    keyword = plugin
    keyword = tool
    keywords = development Dist::Zilla

=head1 DESCRIPTION

This plugin adds metadata to your distribution under the C<keywords> field.
The L<CPAN meta specification|https://metacpan.org/pod/CPAN::Meta::Spec#keywords>
defines this field as:

    A List of keywords that describe this distribution. Keywords must not include whitespace.

=for Pod::Coverage metadata mvp_aliases mvp_multivalue_args

=head1 CONFIGURATION OPTIONS

=head2 C<keyword>, C<keywords>

One or more words to be added as keywords. Can be repeated more than once.
Strings are broken up by whitespace and added as separate words.

=head1 SUPPORT

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-Keywords>
(or L<bug-Dist-Zilla-Plugin-Keywords@rt.cpan.org|mailto:bug-Dist-Zilla-Plugin-Keywords@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 SEE ALSO

=over 4

=item *

L<https://metacpan.org/pod/CPAN::Meta::Spec#keywords>

=back

=head1 AUTHOR

Karen Etheridge <ether@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
