package App::Betting::Toolkit::Client;

use 5.006;
use strict;
use warnings;

use JSON;

use POE qw(Component::Client::TCP);

=head1 NAME

App::Betting::Toolkit::Client - The great new App::Betting::Toolkit::Client!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use App::Betting::Toolkit::Client;

    my $foo = App::Betting::Toolkit::Client->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
	my $class = shift;
	my $args = shift;

	die "No handler or parent passed" if ( ( !$args->{handler} ) || (! $args->{parent} ) );

	my $self;

	# check the state of args:
	# host / port / regmode / handler

	$args->{regmode} = 'anonymous' if (!$args->{regmode});

	$self->{service} = POE::Component::Client::TCP->new(
		RemoteAddress	=> $args->{host},
		RemotePort	=> $args->{port},
		Connected	=> sub {
			my ($heap,$kernel) = @_[HEAP,KERNEL];

			my $msg = { event=>'connected', data=>'' };

			if ($args->{regmode} eq 'anonymous') {
				$heap->{server}->put(encode_json({ query=>'register', keys=>[ qw('special',time) ] }) );
			} elsif ($args->{regmode} eq 'private') {
				die "Implement me";
			} else {
				die "Reg mode must be anonymous or private and nothing else..";
			}

			$kernel->post($args->{parent},$args->{handler},$msg);
	        },
        	ServerInput   => sub {
	                my ($kernel,$input) = @_[KERNEL,ARG0];
        	        print STDERR "from server: $input\n";

			my $req = decode_json($input);

			$kernel->post($args->{parent},$args->{handler},$req);
        	},
		InlineStates  => {
		},
	);

	bless $self, $class;	

	return $self;
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
