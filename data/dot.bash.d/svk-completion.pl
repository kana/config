#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

package Shell::Complete;

sub new
{
	my $proto = shift;
	my $class = ref($proto)? ref $proto: $proto;
	my $self = bless {}, $proto;
	$self->rebless;
	return $self->init(@_);
}

sub rebless
{
	my $self = shift;
	my $shell = $ENV{'SHELL'} || 'bash';
	$shell =~ s/^.*[\\\/]//;
	$shell = ucfirst $shell;
	my $class = 'Shell::Complete::'. $shell;
	# eval "require $class";
	return warn("couldn't find $class") unless UNIVERSAL::can( $class, 'init' );
	if( ref( $self ) eq 'Shell::Complete' ) {
		bless $self, $class;
	} else {
		my $cur = ref $self;
		my @tmp = eval "map s/^Shell::Complete\$/\Q$class\E/, \@$cur\:\:ISA";
		warn $@ if( $@ );
		unless( grep $_, @tmp ) {
			warn "$cur class doesn't inherit interface from Shell::Complete";
		}
	}
	return;
}

sub init { return $_[0] }

sub command { return $_[0]->{'command'} }
sub cur { return $_[0]->{'cur'} }
sub prev { return $_[0]->{'prev'} }
sub line { return $_[0]->{'line'} }
sub pos { return $_[0]->{'pos'} }

sub _set_cur
{
	my $self = shift;
	my $new_cur = shift;
	my $old_cur = $self->cur;
	substr( $self->{'line'}, $self->pos - length($old_cur), length($old_cur) ) =
		$new_cur;
	$self->{'cur'} = $new_cur;
	$self->{'pos'} += length($new_cur) - length($old_cur);
	return $old_cur;
}

sub args { return @{ $_[0]->{'args'} } }

sub at_last_pos { return length($_[0]->line) == $_[0]->pos }

sub is_option { return $_[0]->cur =~ /^-/ }
sub is_long_option { return $_[0]->cur =~ /^--/ }
sub options_strings { return (); }

sub options
{
	my $self = shift;
	my $long = $self->is_long_option;
	my @res = map {	s/[^\w|].*$//;
			split /\|/
		      } $self->options_strings;
		      
	@res = grep length() == 1, @res unless $long;
	return map { length() == 1? "-$_": "--$_" } @res;
}

sub filter_list
{
	my ($self, @list) = @_;
	my $cur = $self->cur;
	return grep /^\Q$cur/, @list;
}

sub output_list
{
	my $self = shift;
	print "$_\n" foreach $self->filter_list( @_ );
	return;
}


1;

package Shell::Complete::Bash;

our @ISA = qw(Shell::Complete);

sub init
{
	my $self = shift;
	$self->{'command'} = $ARGV[0] || die "empty \@ARGV";
	$self->{'cur'} = $ARGV[1] || '';
	$self->{'prev'} = $ARGV[2] || '';
	$self->{'line'} = $ENV{'COMP_LINE'} || die "empty \$ENV{COMP_LINE}";
	$self->{'pos'} = $ENV{'COMP_POINT'} || die "empty \$ENV{COMP_POINT}";
	my( $cmd, @args ) = split /\s+/, $self->{'line'};
	push @args, '' if $self->{'line'} =~ /\s+$/;
	$self->{'args'} = [ @args ];
	return $self;
}

1;

package Shell::Complete::Zsh;

our @ISA = qw(Shell::Complete);

sub init
{
	my $self = shift;
	$self->{'command'} = $ARGV[0] || die "empty \@ARGV";
	$self->{'cur'} = $ARGV[1] || '';
	$self->{'prev'} = $ARGV[2] || '';
	$self->{'line'} = $ENV{'BUFFER'} || die "empty \$ENV{BUFFER}";
	$self->{'pos'} = $ENV{'CURSOR'} || die "empty \$ENV{CURSOR}";
	my( $cmd, @args ) = split /\s+/, $self->{'line'};
	push @args, '' if $self->{'line'} =~ /\s+$/;
	$self->{'args'} = [ @args ];
	return $self;
}

1;

package SVK::Complete;

our @ISA = qw(Shell::Complete);


sub svk_commands
{
	my $self = shift;
	unless( $self->{'svk_commands'} ) {
		require SVK::Command;
		my @cmds = $self->svk_command_aliases;

		require File::Find;
		my $dir = $INC{"SVK/Command.pm"};
		$dir =~ s/\.pm$//;
		File::Find::find(sub { push @cmds, lc() if s/\.pm$// }, $dir );

		my %seen = ();
		@cmds = grep !$seen{$_}++, @cmds;
		$self->{'svk_commands'} = [ sort @cmds ];
	}
	return @{ $self->{'svk_commands'} };
}

# only works for svk >1.04
sub svk_command_aliases
{
	my $self = shift;
	unless( exists $self->{'svk_command_aliases'} ) {
		require SVK::Command;
		local $@;
		my %cmds = (eval { SVK::Command->alias });
		$self->{'svk_command_aliases'} = \%cmds;
	}
	return %{ $self->{'svk_command_aliases'} };
}

sub svk_command
{
	my( $self ) = @_;
	unless( exists $self->{'svk_command'} ) {
		my @args = $self->args;
		my $cur = $self->cur;
		if( scalar(@args) <= 1 ) {
			$self->{'svk_command'} = undef;
		} else {
			my $cmd = $args[0] || '';
			$self->{'svk_command'} = (grep $_ eq $cmd,
						       $self->svk_commands
						 )? $cmd: '';
			my %alias = $self->svk_command_aliases;
			$self->{'svk_command'} = $alias{ $cmd } if $alias{ $cmd };
			# old svk versions <= 1.04 doesn't allow to get aliases map
			# but have util SVK::Command::_cmd_map
			$self->{'svk_command'} ||= eval { SVK::Command::_cmd_map($cmd) } || '';
		}
	}
	return $self->{'svk_command'};
}

sub svk_command_obj
{
	my $self = shift;
	unless( exists $self->{'svk_command_obj'} ) {
		my $cmd = $self->svk_command;
		$cmd = "SVK::Command::". ucfirst($cmd);
		eval "require $cmd";
		die $@ if $@;
		$self->{'svk_command_obj'} = $cmd->new();
	}
	return $self->{'svk_command_obj'};
}

sub options_strings
{
	my $obj = $_[0]->svk_command_obj;
	my %opt = eval{ $obj->command_options };
	%opt = $obj->options if $@;
	return sort keys %opt;
}

sub __svk_sys_path
{
	require File::Spec;
	return $ENV{SVKROOT} || File::Spec->catfile($ENV{HOME}, ".svk");
}

sub __svk_xd
{
	my $self = shift;
	my $svkpath = $self->__svk_sys_path;
	require SVK::XD; require Data::Hierarchy;
	my $xd = SVK::XD->new ( giantlock => File::Spec->catfile($svkpath, 'lock'),
                                statefile => File::Spec->catfile($svkpath, 'config'),
                                svkpath => $svkpath,
                              );
	$xd->load;
	return $xd;
}

sub is_svk_depotname
{
	return $_[0]->cur =~ /^\/[^\/]*$/;
}

sub svk_depotnames
{
	return map "/$_/", sort keys %{$_[0]->__svk_xd->{depotmap}};
}

sub is_svk_depotpath
{
	my $self = shift;
	return unless $self->cur =~ /^(\/[^\/]*\/)/;
	my $dn = $1;
	return unless grep $dn eq $_, $self->svk_depotnames;
	return 1;
}

sub svk_depotpaths
{
	my $self = shift;
	my $cur = $self->cur;
	$cur =~ s/[^\/]+$//;
	my $xd = $self->__svk_xd;

	my $output = '';
	open my $sfh, ">:scalar", \$output or die;
	require SVK::Command;
	eval { require SVK::Path::Checkout };
	eval { require SVK::Target };
	SVK::Command->invoke($xd, 'list', $sfh, "-f", $cur );
	close( $sfh );

	return split /\r*\n/, $output;
}

1;

package main;

my $complete = new SVK::Complete;

# if we aren't at last pos, get out of here
exit unless $complete->at_last_pos;

my @args = $complete->args;

my $svk_command = $complete->svk_command;

unless( defined $svk_command ) {
	$complete->output_list( $complete->svk_commands );
	exit 0;
}

unless( $svk_command ) {
	print STDERR "\nwarning: unknown svk command\n";
	exit 0;
}

if( $complete->is_option ) {
	$complete->output_list( $complete->options );
	exit 0;
}

if( $complete->is_svk_depotname ) {
	my @list = $complete->filter_list( $complete->svk_depotnames );
	unless( @list == 1 ) {
		$complete->output_list( @list );
		exit 0;
	}
	$complete->_set_cur( $list[0] );
}

if( $complete->is_svk_depotpath ) { while(1) {
	my @list = $complete->filter_list( $complete->svk_depotpaths );
	unless( @list == 1 ) {
		$complete->output_list( @list );
		exit 0;
	}
	$complete->_set_cur( $list[0] );
} }


exit 0;

