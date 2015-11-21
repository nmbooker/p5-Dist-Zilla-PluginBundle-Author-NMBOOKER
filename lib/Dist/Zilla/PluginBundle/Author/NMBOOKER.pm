use strict;
use warnings;
package Dist::Zilla::PluginBundle::Author::NMBOOKER;

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

our $VERSION = '0.001';

use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;

sub configure {
    my ($self) = @_;

    $self->add_plugins(qw(
        Git::GatherDir
        Prereqs::FromCPANfile
    ));
    $self->add_bundle('@Filter', {
        '-bundle' => '@Basic',
        '-remove' => [ 'GatherDir', 'TestRelease', ],
    });

    $self->add_plugins(qw(
        AutoPrereqs
        ReadmeFromPod
        MetaConfig
        MetaJSON
        PodSyntaxTests
        Test::Compile
        Test::ReportPrereqs
        CheckChangesHasContent
        RewriteVersion
        NextRelease
        Repository
    ),
        [ Encoding => 
            CommonBinaryFiles => {
                match => '\.(png|jpg|db)$',
                encoding => 'bytes'
        } ],
        # Don't try to weave scripts. They have their own POD.
        [ PodWeaver => { finder => ':InstallModules' } ],
        [ 'Git::Commit' =>
            CommitGeneratedFiles => { 
                allow_dirty => [ qw/dist.ini Changes cpanfile LICENSE/ ]
        } ],
        'ExecDir',
        [ ExecDir =>
            ScriptDir => { dir => 'script' }
        ],
    qw(
        Git::Tag
        BumpVersionAfterRelease
    ),
        ['Git::Commit' => 
            CommitVersionBump => { allow_dirty_match => '^lib/', commit_msg => "Bumped version number" } ],
        'Git::Push',
        [ Prereqs => 'TestMoreWithSubtests' => {
            -phase => 'test',
            -type  => 'requires',
            'Test::More' => '0.96'
        } ],
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;


1;

=encoding utf8

=head1 NAME

Dist::Zilla::PluginBundle::Author::NMBOOKER - Standard behaviour for NMBOOKER's modules

=head1 SYNOPSIS

In your F<dist.ini>:

    [@Author::NMBOOKER]

=head1 DESCRIPTION

This generally implements the workflow that NMBOOKER's modules will use.

It is roughly equivalent to:

  [Git::GatherDir]
  [@Basic]

  [Prereqs::FromCPANfile]
  [AutoPrereqs]
  [ReadmeFromPod]
  [MetaConfig]
  [MetaJSON]
  [PodSyntaxTests]
  [Test::Compile]
  [Test::ReportPrereqs]
  [CheckChangesHasContent]
  [RewriteVersion]
  [NextRelease]
  [Repository]
  [PodWeaver]
  
  [Git::Commit / CommitGeneratedFiles]
  allow_dirty = dist.ini
  allow_dirty = Changes 
  allow_dirty = cpanfile 
  allow_dirty = LICENSE

  [Git::Tag]
  [BumpVersionAfterRelease]
  [Git::Commit / CommitVersionBump]
  allow_dirty_match = ^lib/
  commit_msg = "Bumped version number"

  [Git::Push]

  [Prereqs / TestMoreWithSubtests]
  -phase = test
  -type  = requires
  Test::More = 0.96

=head1 COPYRIGHT

I've based this on a clone of L<Dist::Zilla::PluginBundle::Author::OpusVL>, except that I release to
the real CPAN by default.

  Copyright (C) 2015 Nicholas Booker
  Copyright (C) 2015 OpusVL

License is 3-clause BSD.

=cut
