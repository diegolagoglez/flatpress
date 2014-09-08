# FlatPress

>
> This project is under heavy developement.
>

FlatPress is a really, really simple CMS.

CMS are very complex pieces of software today. They have a database, a template system, a big and great backend… but all that stuff overload the server for **really simple** sites.

With FlatPress you only have to write the contents of your site with the directory structure you want. After that, run `make` and your site will be generated with the same directory structure, and the server will serve it as static HTML. No database needed or a big backend. Only a text editor.

# Dependencies

FlatPress needs this packages:

* A shell (like [BASH](http://en.wikipedia.org/wiki/Bash_%28Unix_shell%29)).
* `make` to build the complete site.
* [`pandoc`](http://johnmacfarlane.net/pandoc/) to convert between MarkDown and HTML.
* `git` (optional) to deploy the Makefile.

# Deployment

In order to deploy the first time a site built with FlatPress you have to follow the next steps:

* Get/clone the [FlatPress respository](https://github.com/diegolagoglez/flatpress.git) in the directory you want (for example in `/var/www/my-flatpress-site`).
* Run `make create-layout` the create the basic directory layout of FlatPress.
* Write your site's contents into `site` directory (`site/articles` directory for articles/posts, `site/pages` for pages and `site/aside` for sidebar/aside contents as [Markdown](http://en.wikipedia.org/wiki/Markdown) files. You can optionally use [Pandoc's Markdown](http://johnmacfarlane.net/pandoc/demo/example9/pandocs-markdown.html) or deploy any other repository with your site's contents.
* Configure the document root of your web server to the `public` directory of your site's directory (for example `DocumentRoot "/var/www/my-flatpress-site/public"`).
* Run `make` in the FlatPress root directory.

# Usage

Once the site has been created, you have to do the next scripts to publish contents:

* Write contentes under `site/contents` directory as markdown.
* Run `make`.
* Done.
* What else?

# Lacks and limitations

Due to this *is* a CMS without backend and a complex publishing workflow, there are some lacks and limitations I am trying to solve:

* The articles/pages have not yet user ~~and date~~ information. The writer is the responsible to write this information into the Markdown file.
* Templates are very limited. You have a header, main contents, footer and aside blocks within you HTML. It is a good oportity to be very imaginative with your CSS and Javascript.
* ~~Although the pages menu is dynamically built, the aside part is still static.~~
* The menu can only go in top part of the page, not in the aside part.

# Credits

Created by [Diego Lago González](mailto:diego.lago.gonzalez@gmail.com)

Version 0.1

GPLv3 — 2014
