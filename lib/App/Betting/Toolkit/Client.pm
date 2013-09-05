package App::Betting::Toolkit::Client;

use 5.006;
use strict;
use warnings;

use App::Betting::Toolkit::GameState;

use Data::Dumper;

use POE qw(Component::Client::TCP Filter::JSON Filter::Stackable Filter::Line );

=head1 NAME

App::Betting::Toolkit::Client - Client to the App::Betting::Toolkit::Server

=head1 VERSION

Version 0.018

=cut

our $VERSION = '0.018';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use App::Betting::Toolkit::Client;

    my $foo = App::Betting::Toolkit::Client->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 new

=over 1

Create a new Betting Client, you need to specify a parent, a handler, a host and a port:

	$_[HEAP]->{client} = App::Betting::Toolkit::Client->new({
		port    => 10001,
		host    => 'my.bet.server.com',
		parent  => 'my_data_source',
		handler => 'my_handler_on_data_source'
	});

=back

=cut

sub new {
	my $class = shift;
	my $args = shift;

	die "No handler or parent passed" if ( ( !$args->{handler} ) || (! $args->{parent} ) );

	my $self;

	# check the state of args:
	# host / port / regmode / handler

	$args->{regmode} = 'anonymous' if (!$args->{regmode});
	$args->{debug_handler} = 'debug_server' if (!$args->{debug_handler});

	my $filter = POE::Filter::JSON->new( json_any => { allow_nonref => 1 } );

	$self->{service} = POE::Component::Client::TCP->new(
		RemoteAddress	=> $args->{host},
		RemotePort	=> $args->{port},
		Filter		=> $filter,
		Started		=> sub {
			$self->{myid} = $_[SESSION]->ID;
		},
		Connected	=> sub {
			my ($heap,$kernel) = @_[HEAP,KERNEL];

			my $msg = { query=>'connected', data=>'' };

			if ($args->{regmode} eq 'anonymous') {
				$heap->{server}->put( $filter->put([{ query=>'register', method=>'anonymous' } ]) );
			} elsif ($args->{regmode} eq 'private') {
				die "Implement me";
				$heap->{server}->put( $filter->put([{ query=>'register', method=>'private', keys=>[] }]) );
			} else {
				die "Reg mode must be anonymous or private and nothing else..";
			}

			$kernel->post($args->{parent},$args->{handler},$msg);
	        },
        	ServerInput   => sub {
	                my ($kernel,$heap,$input) = @_[KERNEL,HEAP,ARG0];

			my $req = $filter->get($input)->[0];
			my $pkt = { error=>1, msg=>"Could not handle server req", req=>$req };

			if ($req->{query} eq 'register') {
				if (!$req->{error}) {
					# Ok we need to know what design of GameState packets the server is expecting.
					my $send = $filter->put([ { query=>'gamepacket', method=>'initial' } ]);
					$heap->{server}->put($send);
					return;
				}
			} elsif ($req->{query} eq 'gamepacket') {
				# Ok we need to remember this.
				$self->{gamepacket} = $req->{data};
				# ok we have a copy of the gamepacket template so we are ready to roll; lets tell the client
				$pkt = { query=>'ready', gamepacket=>$self->{gamepacket} };
			}

			if (!$pkt->{error}) {
				$pkt->{id} = $self->{id};
				$kernel->yield('send_to_parent',$pkt);
			}

			$kernel->post($args->{parent},$args->{debug_handler},$input);
        	},
		InlineStates  => {
			send_to_parent	=> sub {
				my ($kernel,$req) = @_[KERNEL,ARG0];
				$kernel->post($args->{parent},$args->{handler},$req);
			},
			send		=> sub {
				my ($kernel,$heap,$req) = @_[KERNEL,HEAP,ARG0];
				$heap->{server}->put($req);
			},
		},
	);

	bless $self, $class;	

	return $self;
}

sub send {
	my $self = shift;
	my $pkt = shift;

	POE::Kernel->post($self->{myid},'send',$pkt);
}

sub newState {
	my $self = shift;

	my $return = App::Betting::Toolkit::GameState->load($self->{gamepacket});

	return $return;
}


=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Paul G Webster, C<< <daemon at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-betting-toolkit-client at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Betting-Toolkit-Client>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Betting::Toolkit::Client


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Betting-Toolkit-Client>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Betting-Toolkit-Client>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Betting-Toolkit-Client>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Betting-Toolkit-Client/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Paul G Webster.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/bsd-license.php>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Paul G Webster's Organization
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of App::Betting::Toolkit::Client
