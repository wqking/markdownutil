#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use File::Path;

our @replaceList = (
	# TOC
	{
		pattern => qr!~~NOTOC~~!ms,
		replacer => '<!--notoc-->',
		noRecurse => 1,
	},

	# headings
	{
		pattern => qr!={6,6}\s*(.*?)\s*={6,6}!ms,
		replacer => '" . doReplaceHeading($1, 1) . "',
		noRecurse => 1,
	},
	{
		pattern => qr!={5,5}\s*(.*?)\s*={5,5}!ms,
		replacer => '" . doReplaceHeading($1, 2) . "',
		noRecurse => 1,
	},
	{
		pattern => qr!={4,4}\s*(.*?)\s*={4,4}!ms,
		replacer => '" . doReplaceHeading($1, 3) . "',
		noRecurse => 1,
	},
	{
		pattern => qr!={3,3}\s*(.*?)\s*={3,3}!ms,
		replacer => '" . doReplaceHeading($1, 4) . "',
		noRecurse => 1,
	},
	{
		pattern => qr!={2,2}\s*(.*?)\s*={2,2}!ms,
		replacer => '" . doReplaceHeading($1, 5) . "',
		noRecurse => 1,
	},
	
	# text format
	{
		pattern => qr!\*\*\s*(.*?)\s*\*\*!ms,
		replacer => '**$1**'
	},
	{
		pattern => qr!//\s*(.*?)\s*//!ms,
		replacer => '*$1*'
	},
	{
		pattern => qr!\s*\\\\\s*$!ms,
		replacer => '  '
	},
	{
		pattern => qr!~~(.+?)~~!ms,
		replacer => ''
	},
	
	# images
	{
		pattern => qr!\{\{(.*?\.(jpg|png|gif).*?)\}\}!ms,
		replacer => '" . doReplaceImage($1) . "',
		noRecurse => 1,
	},

	# link url
	{
		pattern => qr!\[\[(.+?)\]\]!ms,
		replacer => '" . doReplaceLink($1) . "',
		noRecurse => 1,
	},

	# special
	{
		pattern => qr!\{\{tag.*?\}\}!ms,
		replacer => ''
	},
);

# map Dokuwiki syntax highlight language to Markdown
our %langMap = (
	'cpp' => 'c++',
);

our %linkTitleMap = (
);

my $args = {
	'output' => './output',
	'imagePrefix' => '',
	'htmlImage' => 1,
	'config' => '',
	'patterns' => [],
};

&doMain;

sub doMain
{
	$args = &doParseArgs;
	
	File::Path::make_path($args->{output});
	
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
		if($arg =~ /^\-\-output=(.*)/) {
			$args->{output} = $1;
		}
		elsif($arg =~ /^\-\-image\-prefix=(.*)/) {
			$args->{imagePrefix} = $1;
		}
		elsif($arg =~ /^\-\-html\-image=(.*)/) {
			$args->{htmlImage} = $1 + 0;
		}
		elsif($arg =~ /^\-\-config=(.*)/) {
			$args->{config} = $1;
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
	
	if($args->{config} ne '') {
		require($args->{config});
	}
	
	return $args;
}

sub usage
{
	my ($message) = @_;
	
	print $message, "\n" if defined($message);
	print <<EOM;
doku2md version 0.1.
Github: https://github.com/wqking/markdownutil

doku2md converts Dokuwiki document to Github flavored Markdown document.

usage: perl doku2md.pl [options] inputFile [more inputFile]
options:
    --output=FOLDER          Specify the output folder to FOLDER for the
                             generated .md files. Default is ./output.
    --image-prefix=PREFIX    For each embedded images, add the PREFIX before
                             the image link. Useful to set the image folder.
    --html-image=1           1 to use HTML '<img>' tag for image. 0 to use
                             markdown '![]()' for image. Default is 1.
    --config=PERLSCRIPT      The PERLSCRIPT is executed in doku2md, the script
                             can modify any 'our' variables in doku2md.
inputFile: The file name of the Dokuwiki page file. It can contain wildcard.
The inputFile can be specified multiple times.
EOM

	die "\n";
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
	my ($inputFileName, $outputPath) = @_;
	
	return unless(open FH, '<' . $inputFileName);
	my $content = join('', <FH>);
	close FH;
	
	$content = &doConvertText($content);

	my $outputFileName = basename($inputFileName);
	$outputFileName =~ s/\.html\.txt$/.txt/;
	if(! ($outputFileName =~ s/\.[^.]+$/.md/)) {
		$outputFileName .= '.md';
	}
	$outputFileName = $outputPath . '/' . $outputFileName;
	
	if(open OFH, '>' . $outputFileName) {
		print OFH $content;
		close OFH;
	}
}

sub doConvertText
{
	my ($text) = @_;
	
	my @codeBlockList = ();
	my $codeBlockTag = 'cBt;7=,wpEf';
	while(1) {
		my $tag = $codeBlockTag . sprintf('%05d', scalar(@codeBlockList));
		if($text =~ s!^\s*<\s*code(\s+.*?)\s*>(.*?)<\s*/code\s*>!$tag!mse) {
			my ($lang, $content) = ($1, $2);
			$content =~ s/^\s+//s;
			$content =~ s/\s+$//s;
			push @codeBlockList, {
				'tag' => $tag,
				'lang' => $lang,
				'content' => $content
			};
		}
		else {
			last;
		}
	}
	
	$text = &doReplaceText($text);
	
	foreach my $codeBlock (@codeBlockList) {
		my $lang = defined($codeBlock->{lang}) ? $codeBlock->{lang} : '';
		$lang =~ s/\s//g;
		$lang = $langMap{$lang} if defined($langMap{$lang});
		my $replacement = "```$lang\n" . $codeBlock->{content} . "\n```";
		$text =~ s/$codeBlock->{tag}/$replacement/;
	}
	
	return $text;
}

sub doReplaceText
{
	my ($text) = @_;

	foreach my $r (@replaceList) {
		my $replacement = '"' . $r->{replacer} . '"';
		$replacement =~ s/(\$\d)/" . doReplaceText($1) . "/g unless $r->{noRecurse};
		$text =~ s/$r->{pattern}/$replacement/gee;
	}
	
	return $text;
}

sub doReplaceHeading
{
	my ($text, $depth) = @_;
	
	my $result = '#' x $depth;
	$result .= ' ';
	$result .= $text;
	
	return $result;
}

sub doCreateLinkTitle
{
	my ($url) = @_;
	my $title = $url;
	if(defined $linkTitleMap{$url}) {
		$title = $linkTitleMap{$url};
	}
	return $title;
}

sub doReplaceLink
{
	my ($text) = @_;
	
	my $title = '';
	my $url = '';

	if($text =~ /([^:]+?)\|(.*)/) {
		$title = $2;
		$url = $1;
		$url =~ s/\.htm.?\s*$/.md/;
	}
	
	if($title eq '') {
		$title = doCreateLinkTitle($url);
	}
	
	my $result = '';
	$result .= '[' . $title . '](' . $url . ')';
	
	return $result;
}
	
sub doReplaceImage
{
	my ($text) = @_;
	
	my $title = '';
	my $fileName = '';
	my $width = '';
	my $height = '';
	
	if($text =~ /([^:]+?\.)(jpg|png|gif)\b/) {
		$fileName = $1 . $2;
	}
	if($text =~ /[\?\&](\d+)x(\d+)/) {
		$width = $1;
		$height = $2;
	}
	elsif($text =~ /[\?\&](\d+)/) {
		$width = $1;
	}
	if($text =~ /\|(.*)/) {
		$title = $1;
	}
	
	$fileName = $args->{imagePrefix} . $fileName;
	
	if($title eq '') {
		$title = $fileName;
	}
	
	my $result = '';
	if($args->{htmlImage}) {
		$result .= '<img src="' . $fileName . '"';
		if($width ne '') {
			$result .= ' width=' . $width;
		}
		if($height ne '') {
			$result .= ' height=' . $height;
		}
		$result .= ' />';
	}
	else {
		$result .= '![' . $title . '](' . $fileName;
		if($width ne '') {
			$result .= ' =' . $width . 'x';
		}
		if($height ne '') {
			$result .= $height;
		}
		$result .= ')';
	}
	
	return $result;
}
