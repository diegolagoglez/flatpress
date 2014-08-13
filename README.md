# FlatPress

>
> This project is under heavy developement.
>

FlatPress is a really, really simple CMS.

CMS are very complex pieces of software today. They have a database, a template system, a big and great backend… but all that stuff overload the server for really simple sites.

With FlatPress you only have to write the contents of your site with the directory structure you want. After that, run `make` and your site will be generated with the same directory structure, and the server will serve it as static HTML. No database needed or a big backend. Only a text editor.

# Dependencies

FlatPress needs this packages:

* `make` to build the complete site.
* [`pandoc`](http://johnmacfarlane.net/pandoc/) to convert between MarkDown and HTML.
* `git` (optional) to deploy the Makefile.

# Deployment

In order to deploy the first time a site built with FlatPress you have to follow the next steps:

* Get/clone the [FlatPress respository](https://github.com/diegolagoglez/flatpress.git).
* Create a directory to hold your site (for example at `/var/www/my-flatpress-site`).
* Copy the `Makefile` into that directory.
* Run `make create-layout` the create the basic directory layout of FlatPress.
* Configure the document root of your web server to the `public` directory of your site's directory (for example `DocumentRoot "/var/www/my-flatpress-site/public"`).
* Create the template in the `template` directory.
* Create all your static resources (styles, images and scripts) in the `static` directory under the corresponding subdirectories.
* Write the contents in the `private` directory as markdown files.
* Run `make` in the FlatPress root directory.

# Usage

Once the site has been created, you have to do the next scripts to publish contents:

* Write contentes under `private` directory as markdown files (and under directory layout you want).
* Run `make`.
* Done.
* What else?

# Example

Not yet.

# Credits

Created by [Diego Lago González](mailto:diego.lago.gonzalez@gmail.com)

Version 0.1

GPLv3 — 2014
