# addtoc2md.pl -- Adds table of contents to Github flavored Markdown files

**This tool is deprecated and not maintained. Please use the [Python tool markdown-toc](https://github.com/wqking/markdown-toc)**

## Overview

addtoc2md.pl creates and insert table of contents to Github flavored Markdown file.  
The TOC is generated from the headings in the markdown document.  

## Features  

* Use `<a>` anchor tag as the TOC target. It doesn't depend on Github auto anchor feature.  
* Can selectively generate TOC for lengthy article with enough headings. (The `--min-headings` option)
* Repeating the command on the same file will replace the previous TOC instead of adding more TOC.
* Code blocks can be handled correctly, the code lines start with '#' won't be treated as headings.  

## Command line usage
`perl addtoc2md.pl [options] inputFile [more inputFile]`

options

* --min-headings=N : Set minimum heading count to N. If the valid heading count is smaller than N, no TOC is created. Default is 6.
* --min-level=N : Set minimum level to N. A heading level smaller than N is invalid and not included in TOC. Default is 2.
* --max-level=N : Set maximum level to N. A heading level larger than N is invalid and not included in TOC. Default is 3.
* --front=0 : 0 to put the TOC after the first valid heading. 1 to put the TOC in front of the document. Default is 0. The is option is not used if there is `<!--toc-->` tag in the document.
* --clear : Remove all generated TOC. Don't generate new TOC. `<!--toc-->` is placed where the TOC was. This option creates clean document files that are easier to edit.
* --before-toc=S : Put the text S before the TOC. A new line is added between S and TOC. `\n` is replaced with new line break. `\\` is replaced with `\`. A typical usage is "--before-toc=## Table Of Contents\n".
* --after-toc=S : Put the text S after the TOC. A new line is added between TOC and S. S is replaced with the same rules as --before-toc.

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

Because I need some of the features missing from the other tools,

1. Use `<a>` anchor tag as the TOC target. So that the existing markdown-to-HTML converter is happy with the TOC.  
2. Selectively generate TOC for long articles that contain enough headers. I don't want to add `<!--toc->` for every article manually, and I want only longer article has TOC. This is how the command option '--min-headings' is useful.
