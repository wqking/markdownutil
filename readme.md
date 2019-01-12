# A collection of Perl scripts to manipulate markdown files

MarkdownUtil is a collection of Per scripts that can manipulate markdown files.

All scripts require Perl 5 (not Perl 6), the minimum Perl version is Perl 5.8.

## License

Apache License, Version 2.0  

## The scripts

### addtoc2md.pl

Adds table of contents to Github flavored Markdown files.

**Features**  

* Use `<a>` anchor tag as the TOC target. It doesn't depend on Github auto anchor feature.  
* Can selectively generate TOC for lengthy article with enough headings. (The `--min-headings` option)
* Repeating the command on the same file will replace the previous TOC instead of adding more TOC.
* Code blocks can be handled correct, the code lines start with '#' won't be treated as headings.  

**[Document for addtoc2md](doc/addtoc2md.md)**

### doku2md.pl

Converts Dokuwiki page files to Github flavored Markdown files.  

**Features**  

* Support basic heading and format syntax.  
* Support URL link syntax.  
* Support image syntax.  
* Customizable.  

**[Document for doku2md](doc/doku2md.md)**

## Pull requests are welcome

Even though the scripts are quite simple, here are some work you can contribute.  

* Convert the Perl scripts to Python and PHP.  
* Add more functions to the scripts.  