# doku2md.pl -- Convert Dokuwiki document to Github flavored Markdown document

## Overview

doku2md.pl convert Dokuwiki .txt document to Github flavored Markdown .md document.  

Supported Dokuwiki syntax

* Heading
* Bold and italic
* Link
* Image

More syntax can be added easily.

## Command line usage
`perl doku2md.pl [options] inputFile [more inputFile]`

options

* --output=FOLDER : Specify the output folder to FOLDER for the generated .md files. Default is ./output.
* --image-prefix=PREFIX : For each embedded images, add the PREFIX before the image link. Useful to set the image folder.
* --config=PERLSCRIPT : The PERLSCRIPT is executed in doku2md, the script can modify any 'our' variables in doku2md.

inputFile: The file name of the Dokuwiki page file. It can contain wildcard. The inputFile can be specified multiple times.
