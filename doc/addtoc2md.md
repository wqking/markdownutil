# addtoc2md.pl -- Adds table of content to Github flavored Markdown files

## Overview

addtoc2md.pl creates and insert table of content to Github flavored Markdown file.  
The TOC is generated from the headings in the markdown document.  
Code blocks can be handled correct, the code lines start with '#' won't be treated as headings.

## Command line usage
`perl addtoc2md.pl [options] inputFile [more inputFile]`

options

* --min-headings=N : Set minimum heading count to N. If the valid heading count is smaller than N, no TOC is created. Default is 6.
* --min-depth=N : Set minimum depth to N. A heading depth smaller than N is invalid and not included in TOC. Default is 2.
* --max-depth=N : Set maximum depth to N. A heading depth larger than N is invalid and not included in TOC. Default is 3.
* --front=0 : 0 to put the TOC after the first valid heading. 1 to put the TOC in front of the document. Default is 0. The is option is not used if there is <!--toc--> mark in the document.

inputFile  
The file name of the markdown file (.md). It can contain wildcard. The inputFile can be specified multiple times.
