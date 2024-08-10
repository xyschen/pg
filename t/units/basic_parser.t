#!/usr/bin/env perl

=head1 NumberWithUnits

Test the basic functionality of the NumberWithUnits parser,
F<macros/parserNumberWithUnits.pl>, to demonstrate that the parser and its
methods are working.

=head2 TODO list

=over 4

=item Fix display of temperature units

=item Test adding new units

=item Look up how to get the value of the object instead of reaching into the hashref

=item Test messages from wrong student answer submissions

=back

=cut

use Test2::V0 '!E', { E => 'EXISTS' };

die "PG_ROOT not found in environment.\n" unless $ENV{PG_ROOT};
do "$ENV{PG_ROOT}/t/build_PG_envir.pl";

use lib "$ENV{PG_ROOT}/lib";

use Parser::Legacy::NumberWithUnits;
use Units;

loadMacros('parserNumberWithUnits.pl');
loadMacros('parserFormulaWithUnits.pl');

# define some basic objects
my $joule             = NumberWithUnits(1, 'J');
my $Nm                = NumberWithUnits(1, 'N*m');
my $energy_base_units = NumberWithUnits(1, 'kg*m^2/s^2');

subtest 'Verify classes and methods' => sub {
	isa_ok $joule, 'Parser::Legacy::NumberWithUnits';
	can_ok $joule, [
		qw/cmp splitUnits getUnitNames getUnits TeXunits cmp_parse
			add_fundamental_unit add_unit string TeX /
		],
		'Can we NumberWithUnits';

	ok my $evaluator = $joule->cmp, 'Get an AnswerEvaluator';
	isa_ok $evaluator, 'AnswerEvaluator';
	can_ok $evaluator, [qw/ evaluate /], 'We Can Evaluate';
};

subtest 'Check attributes' => sub {
	is(
		$joule,
		{
			data      => [1],
			units     => 'J',
			units_ref => {
				kg     => 1,
				m      => 2,
				s      => -2,
				factor => 1,
				amp    => 0,
				cd     => 0,
				mol    => 0,
				rad    => 0,
				degC   => 0,
				degF   => 0,
				K      => 0,
			},
			isValue => T(),
			context => check_isa 'Parser::Context'
		},
		'This looks like a joule'
	);
};

subtest 'Basic definitions of energy equivalence' => sub {
	is $joule->{data}->[0], $Nm->{data}->[0], 'One joule is one newton-metre';
	is $joule->getUnits,    $Nm->getUnits,    'A joule has the same dimensions as a newton-metre';

	is(check_score($joule, $Nm),                1, 'A Joule is a Newton-metre');
	is(check_score($joule, $energy_base_units), 1, 'A Joule can be expressed in SI base units');
};

subtest 'Test error handling' => sub {
	my $fake = 'bleurg';

	like(
		dies { NumberWithUnits(1, "$fake") },
		qr/Unrecognizable unit: \|$fake\|/,
		"No unit '$fake' defined in Units file"
	);
	like(dies { NumberWithUnits(1) }, qr/You must provide units for your number/, 'No unit given');
	like(
		dies { NumberWithUnits('J') },
		qr/You must provide units for your number/,
		'No value given, wants 2 arguments'
	);
};

subtest 'Check parsing of arguments' => sub {
	ok my $three_args = NumberWithUnits(1, 'N', 'm'), 'Ignores extra argument';
	is $three_args->string, '1 N', 'Only sees the first unit';

	ok my $string_arg = NumberWithUnits('1J'), 'Parses string argument';
	is $string_arg->string, '1 J', 'Parses string correctly';
};

subtest 'Check some known units' => sub {
	ok my @unit_names = (split /\|/, $joule->getUnitNames), 'Can getUnitNames';

	is \@unit_names, bag {
		all_items(match qr/^(?:[-%\w]+|\p{L}|\p{S}\w?)$/);
		item 'J';
		item 'N';
		item 'm';
		item 'kg';
		item 's';
		etc;
	}, 'Basic units loaded, sanity check';
};

subtest 'Check other methods' => sub {
	is [ $joule->splitUnits ], [ '1', 'J' ], 'splitUnits creates an array';
};

subtest 'Check display methods' => sub {
	is $joule->string,   '1 J',           'Displays string - Joule';
	is $joule->TeX,      '1\ {\rm J}',    'Displays LaTeX string - Joule';
	is $joule->TeXunits, '{\rm 1 J}',     'Displays LaTeX string - Joule';
	is $Nm->TeX,         '1\ {\rm N\,m}', 'Displays LaTeX string - Newton metre';
	like $energy_base_units->TeX,
		qr/ 1\\ \s \{ \S* \\frac\{ \\rm\S* \s kg \\, m\^\{2\}\} \{\\rm\S* \s s\^\{2\}\}\} /x,
		'Displays LaTeX string - energy in SI base units';

	ok my $celsius = NumberWithUnits(1, 'degC');
	ok my $kelvin  = NumberWithUnits(1, 'degK');
	ok 'Display of degrees' => sub {
		is $celsius->TeX, '1\ {\rm ^{\circ}C}', 'Displays LaTeX string for degrees';
		is $kelvin->TeX,  '1\ {\rm K}',         'Displays LaTeX string for kelvin, no degree sign';
	};
};

subtest 'Check possible answer format branches' => sub {
	# re-write without check_score so we can get the messages to students

	is check_score($joule, '1 J'),       1, 'one Joule plain';
	is check_score($joule, '1.00 J'),    1, 'one Joule float';
	is check_score($joule, '1E0 J'),     1, 'one Joule exponential notation';
	is check_score($joule, '7/7 J'),     1, 'one Joule value calculated';
	is check_score($joule, '1 J^1'),     1, 'one Joule to the power of one';
	is check_score($joule, 'J 1'),       0, 'one Joule wrong order';
	is check_score($joule, '2 J'),       0, 'one Joule wrong value';
	is check_score($joule, '1 j'),       0, 'one Joule wrong case';
	is check_score($joule, '1'),         0, 'one Joule missing unit';
	is check_score($joule, 'J'),         0, 'one Joule missing value';
	is check_score($joule, '1J'),        1, 'one Joule missing space between value and unit is valid';
	is check_score($joule, '1 N'),       0, 'one Joule wrong unit force not energy';
	is check_score($joule, '1 Nm'),      0, 'one Joule Nm missing *';
	is check_score($joule, '1 N*m'),     1, 'one Joule as Newton metre';
	is check_score($joule, '1 Joule'),   0, 'one Joule in words';
	is check_score($joule, '1E-3 kJ'),   1, 'one Joule value as exponential';
	is check_score($joule, '0.001 kJ'),  1, 'one Joule decimal kJ';
	is check_score($joule, '1/1000 kJ'), 1, 'one Joule fractional kJ';
	is check_score($joule, '10^-3 kJ'),  1, 'one Joule latex power kJ';
	is check_score($joule, '10**-3 kJ'), 1, 'one Joule power of 10 kJ';
};

subtest 'Check possible answers compared to the number 0.005 T' => sub {
	my $correct = NumberWithUnits('0.005 T');

	is check_score($correct, '0.005 T'),               1, '0.005 T is correct';
	is check_score($correct, '5*10^-13 T*m/angstrom'), 1, '5*10^-13 T*m/angstrom is correct';
	is check_score($correct, '0 T*m/angstrom'),        0, '0 T*m/angstrom is incorrect';
};

subtest 'Check possible answers compared to the formula 0.005 T' => sub {
	my $correct = FormulaWithUnits('0.005 T');

	is check_score($correct, '0.005 T'),               1, '0.005 T is correct';
	is check_score($correct, '5*10^-13 T*m/angstrom'), 1, '5*10^-13 T*m/angstrom is correct';
	is check_score($correct, '0 T*m/angstrom'),        0, '0 T*m/angstrom is incorrect';
};

subtest 'Check possible answers compared to the formula 0.009 x^2 T' => sub {
	my $correct = FormulaWithUnits('0.009 x^2 T');

	is check_score($correct, '0.009 x^2 T'),               1, '0.009 x^2 T is correct';
	is check_score($correct, '9*10^-13 x^2 T*m/angstrom'), 1, '9*10^-13 x^2 T*m/angstrom is correct';
	is check_score($correct, '0 T*m/angstrom'),            0, '0 T*m/angstrom is incorrect';
	is check_score($correct, '0 x^2 T*m/angstrom'),        0, '0 x^2 T*m/angstrom is incorrect';
};

subtest 'Check possible answers compared to the the number 1 amu' => sub {
	my $correct = NumberWithUnits('1 amu');

	is check_score($correct, '1 amu'),                 1, '1 amu is correct';
	is check_score($correct, '2 amu'),                 0, '2 amu is incorrect';
	is check_score($correct, '1.660538921*10^-27 kg'), 1, '1.660538921*10^-27 kg is correct';
	is check_score($correct, '0 kg'),                  0, '0 kg is incorrect';
	is check_score($correct, '1.660538921*10^-24 g'),  1, '1.660538921*10^-24 g is correct';
	is check_score($correct, '0 g'),                   0, '0 g is incorrect';
	is check_score($correct, '1.1374*10^-28 slug'),    1, '1.1374*10^-28 slug is correct';
};

done_testing;
