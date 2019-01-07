#!/usr/bin/perl
use strict;
use warnings;

my $args = {
	minHeadingCount => 6,
	minDepth => 2,
	maxDepth => 3,
	atFront => 0
};

&doMain;

sub doMain
{
	$args = &doParseArgs;
	
	foreach my $pattern (@{$args->{patterns}}) {
		&doProcessPattern($pattern);
	}
}

sub doParseArgs
{
	if(scalar(@ARGV) == 0) {
		&usage;
	}

	foreach my $arg (@ARGV) {
		if($arg =~ /^\-\-min\-headings=(.*)/) {
			$args->{minHeadingCount} = $1 + 0;
		}
		elsif($arg =~ /^\-\-max\-depth=(.*)/) {
			$args->{maxDepth} = $1 + 0;
		}
		elsif($arg =~ /^\-\-front=(.*)/) {
			$args->{atFront} = $1 + 0;
		}
		elsif($arg =~ /^\-(.*)/) {
			die sprintf("Unknow option -%s.\n", $1);
		}
		else {
			push @{$args->{patterns}}, $arg;
		}
	}
	
	if(scalar(@{$args->{patterns}}) == 0) {
		die "Need input patterns.\n";
	}
	
	return $args;
}

sub usage
{
}

sub doProcessPattern
{
	my ($pattern) = @_;
	my @files = glob($pattern);
	foreach my $file (@files) {
		next unless -f ($file);
		&doProcessFile($file, $args->{output});
	}
}

sub doProcessFile
{
	my ($fileName) = @_;
	
	return unless(open FH, '<' . $fileName);
	my @lineList = <FH>;
	close FH;
	
	my $lines = \@lineList;
	
	my $canAdd = (doGetHeadingCount($lines) >= $args->{minHeadingCount}) && ! doHasNoToc($lines);
	
	$lines = doRemoveToc($lines);
	$lines = doAddAnchors($lines, $canAdd);
	
	if($canAdd) {
		my $toc = doBuildToc($lines);
		my $newLines = doAddTocAtTag($lines, $toc);
		if(defined($newLines)) {
			$lines = $newLines;
		}
		elsif($args->{atFront}) {
			unshift(@{$lines}, $toc);
		}
		else {
			$lines = doAddTocAfterFirstHeading($lines, $toc);
		}
	}
	
	if(open OFH, '>' . $fileName) {
		print OFH join('', @{$lines});
		close OFH;
	}
}

sub isValidDepth
{
	my ($depth) = @_;
	
	return $depth >= $args->{minDepth} && $depth <= $args->{maxDepth};
}

sub doGetAnchorID
{
	my ($depth, $count) = @_;
	
	return sprintf('a%d_%d', $depth, $count);
}

sub doTrim
{
	my ($s) = @_;
	
	$s =~ s/^\s+//;
	$s =~ s/\s+$//;
	
	return $s;
}

sub doGetHeadingCount
{
	my ($inputLines) = @_;
	my $count = 0;
	doIterateHeadings($inputLines, sub {
		my ($userData) = @_;
		if(isValidDepth($userData->{depth})) {
			++$count;
		}
		return $userData->{line};
	});
	return $count;
}

sub doHasNoToc
{
	my ($inputLines, $toc) = @_;
	
	my $has = 0;

	my $newLines = doIterateLines($inputLines, sub {
		my ($line) = @_;
		
		if($line =~ /^\s*\<\!\-\-\s*notoc\s*\-\-\>/) {
			$has = 1;
		}
		return $line;
	});
	
	return $has;
}

sub doAddTocAtTag
{
	my ($inputLines, $toc) = @_;
	
	my $added = 0;

	my $newLines = doIterateLines($inputLines, sub {
		my ($line) = @_;
		
		if($line =~ /^\s*\<\!\-\-\s*toc\s*\-\-\>/) {
			$added = 1;
			return ($toc);
		}
		return $line;
	});
	
	return $added ? $newLines : undef;
}

sub doAddTocAfterFirstHeading
{
	my ($inputLines, $toc) = @_;
	return doIterateHeadings($inputLines, sub {
		my ($userData) = @_;
		if($userData->{totalCount} == 1) {
			return ($userData->{line}, $toc);
		}
		return $userData->{line};
	});
}

sub doRemoveToc
{
	my ($inputLines) = @_;

	my $inToc = 0;
	
	return doIterateLines($inputLines, sub {
		my ($line) = @_;
		
		if($line =~ /^\s*\<\!\-\-\s*(begintoc|endtoc)\s*\-\-\>/) {
			$inToc = ($1 eq 'begintoc');
			if(! $inToc) {
				return "<!--toc-->\n";
			}
			return ();
		}
		return () if($inToc);
		return $line;
	});
}

sub doBuildToc
{
	my ($lines) = @_;
	
	my $data = {
		previousDepth => 10000,
		indentLevel => 0
	};
	
	my $result = '';
	
	$result .= "<!--begintoc-->\n";
	
	doIterateHeadings($lines, sub {
		my ($userData) = @_;
		my $depth = $userData->{depth};
		if(isValidDepth($depth)) {
			if($depth < $data->{previousDepth}) {
				--$data->{indentLevel};
				$data->{indentLevel} = 0 if $data->{indentLevel} < 0;
			}
			if($depth > $data->{previousDepth}) {
				++$data->{indentLevel};
			}
			my $anchorId = &doGetAnchorID($userData->{depth}, $userData->{counts}->[$userData->{depth}]);
			$result .= '  ' x $data->{indentLevel};
			$result .= sprintf('* [%s](#%s)', doTrim($userData->{title}), $anchorId);
			$result .= "\n";
			
			$data->{previousDepth} = $depth;
		}
		return $userData->{line};
	});

	$result .= "<!--endtoc-->\n";
	
	return $result;
}

sub doAddAnchors
{
	my ($lines, $canAdd) = @_;
	
	return doIterateHeadings($lines, sub {
		my ($userData) = @_;
		my $resultLines = $userData->{resultLines};
		my $resultLineCount = scalar(@{$resultLines});
		if($resultLineCount > 0 && $resultLines->[$resultLineCount - 1] =~ /^\s*\<a\s+/) {
			pop(@{$resultLines});
		}
		if($canAdd && isValidDepth($userData->{depth})) {
			my $anchorId = &doGetAnchorID($userData->{depth}, $userData->{counts}->[$userData->{depth}]);
			my $anchor = sprintf('<a id="%s"></a>' . "\n", $anchorId);
			return (
				$anchor,
				$userData->{line}
			);
		}
		return $userData->{line};
	});
}

sub doIterateLines
{
	my ($lines, $callback, $userData) = @_;

	my $resultLines = [];
	
	my $inCode = 0;
	
	foreach my $line (@{$lines}) {
		if($line =~ /^\s*```/) {
			$inCode = ! $inCode;
		}

		if($inCode) {
			push @{$resultLines}, $line;
		}
		else {
			push @{$resultLines}, $callback->($line, $userData, $resultLines);
		}
	}
	
	return $resultLines;
}

sub doIterateHeadings
{
	my ($inputLines, $callback) = @_;

	my $data = {
		depth => 0,
		title => '',
		line => '',
		resultLines => undef,
		counts => [ 0, 0, 0, 0, 0, 0, 0, 0 ],
		totalCount => 0
	};
	
	return doIterateLines($inputLines, sub {
		my ($line, $userData, $resultLines) = @_;
		
		if($line =~ /^\s*(#+)(.*)/) {
			$data->{depth} = length($1);
			$data->{title} = $2;
			$data->{line} = $line;
			$data->{resultLines} = $resultLines;
			
			++$data->{counts}->[$data->{depth}];
			++$data->{totalCount};

			return $callback->($data);
		}
		return $line;
	});
}
