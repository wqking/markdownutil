# addtoc2md.pl -- Adds table of content to Github flavored Markdown files

## Overview

addtoc2md.pl creates and insert table of content to Github flavored Markdown file.  
The TOC is generated from the headings in the markdown document.  

## Features  

* Use `<a>` anchor tag as the TOC target. It doesn't depend on Github auto anchor feature.  
* Can selectively generate TOC for lengthy article with enough headings. (The `--min-headings` option)
* Repeated calling the command on the same file will replace the previous TOC, not add more TOC.
* Code blocks can be handled correct, the code lines start with '#' won't be treated as headings.  
* The generated TOC doesn't depend on Github auto anchor features.  

## Command line usage
`perl addtoc2md.pl [options] inputFile [more inputFile]`

options

* --min-headings=N : Set minimum heading count to N. If the valid heading count is smaller than N, no TOC is created. Default is 6.
* --min-depth=N : Set minimum depth to N. A heading depth smaller than N is invalid and not included in TOC. Default is 2.
* --max-depth=N : Set maximum depth to N. A heading depth larger than N is invalid and not included in TOC. Default is 3.
* --front=0 : 0 to put the TOC after the first valid heading. 1 to put the TOC in front of the document. Default is 0. The is option is not used if there is `<!--toc-->` tag in the document.

inputFile  
The file name of the markdown file (.md). It can contain wildcard. The inputFile can be specified multiple times.  
Note: The TOC is written back to `inputFile`. You'd better backup your files before executing the command.

## Special tags

Several tags can be added to the markdown document to help addtoc2md to generate the TOC.

### Tag toc

Syntax: `<!--toc-->`  
It indicates where to put the TOC. The generated TOC will replace `<!--toc-->`.  
`<!--toc-->` can be omitted. If there is no `<!--toc-->`, then the place of TOC is determinted by the command option `--front`. If `--front` is 0 (the default value), the TOC is placed right after the first valid heading (so if the first heading is a H1, the TOC is placed after the H1). If `--front` is 1, the TOC is placed in front of the document.

### Tag begintoc and endtoc

Syntax: `<!--begintoc-->`, `<!--endtoc-->`   
These two tags are created by addtoc2md and usually don't need to add manually. They indicates where the TOC is in. The script can replace the TOC correctly next time the script runs.  
Don't remove the tags from the markdown.  

## Sample

If we have the markdown as

```
# I'm h1

## I'm h2
### I'm h3
## I'm another h2
```

The generated markdown will be

```
# I'm h1
<!--begintoc-->
* [I'm h2](#a2_1)
  * [I'm h3](#a3_1)
* [I'm another h2](#a2_2)
<!--endtoc-->

<a id="a2_1"></a>
## I'm h2
<a id="a3_1"></a>
### I'm h3
<a id="a2_2"></a>
## I'm another h2
```

## Why anther tool while there are existing tools to add TOC to markdown?

Because I need some features lacked in other tools  

1. Use `<a>` anchor tag as the TOC target. So that the existing markdown-to-HTML converter is happy with the TOC.  
2. Selectively generate TOC for lengthy article with enough headings. I don't want to add `<!--toc->` for every article manually, and I want only longer article has TOC.
