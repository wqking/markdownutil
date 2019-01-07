# doku2md.pl -- Convert Dokuwiki document to Github flavored Markdown document

## Overview

doku2md.pl convert Dokuwiki .txt document to Github flavored Markdown .md document.  

Supported Dokuwiki syntax

* Heading
* Bold and italic
* Link
* Image -- the width and height attributes can be converted correctly.

More syntax can be added easily.

## Command line usage
`perl doku2md.pl [options] inputFile [more inputFile]`

options

* --output=FOLDER : Specify the output folder to FOLDER for the generated .md files. Default is ./output.
* --image-prefix=PREFIX : For each embedded images, add the PREFIX before the image link. Useful to set the image folder.
* --html-image=1 : 1 to use HTML `<img>` tag for image. 0 to use markdown `![]()` for image. Default is 1.
* --config=PERLSCRIPT : The PERLSCRIPT is executed in doku2md, the script can modify any 'our' variables in doku2md.

inputFile: The file name of the Dokuwiki page file. It can contain wildcard. The inputFile can be specified multiple times.

## Command line examples

```
perl doku2md.pl cpgf.org\*.txt --image-prefix=images/ --output=cpgf\doc\ --config=cpgf.config.pl
```

This command was used to convert [cpgf library](https://github.com/cpgf/cpgf) document on cpgf.org to markdown.  
The Dokuwiki .txt files are in folder cpgf.org.  
doku2md will write generated .md files to folder cpgf\doc.  
All image URLs are prefixed with images/, so an image URL looks like  
`<img src="images/cpgf-irrlicht-01-helloworld-js.jpg" width=300 />`

Here is the content of cpgf.config.pl

```
%linkTitleMap = (
	'what-cpgf-is-and-is-not.md' => 'What cpgf is and is not',
	'serialization-core-concepts-data-types.md' => 'Inside cpgf serialization -- core concepts and data types',
	'serialization-implement-storage.md' => 'Inside cpgf serialization -- implement storage layer',
	'serialization-implement-serializer.md' => 'Inside cpgf serialization -- implement serializer',
	'cpgf-tween-library.md' => 'cpgf tween library',
	'accessor-getter-setter.md' => 'cpgf Accessor library -- generic getter and setter for data accessing',
);
```

