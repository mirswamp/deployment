# Welcome to SWAMP-in-a-Box! (Software Assurance Marketplace in a Box)

This release of SWAMP-in-a-Box is an open-beta version. We welcome your
feedback, contributions, and questions at support@continuousassurance.org.
To get updates on SWAMP-in-a-Box and be part of the user community, please
[join
our mailing list](https://lists.cosalab.org/mailman/listinfo/swampinabox)!


## Installing

Review the [system requirements for SWAMP-in-a-Box][1]. If your host meets
the requirements, download the installer by:

* Using our download script: Copy **[the download script][2]** to the host
  (right click on the link to save the file). Then, run the script.

* Downloading the files directly: Copy all the files from **[the release
  directory at swampinabox.org][3]** into a single directory on the host.

After you have downloaded the installer, unpack and run it by following the
[instructions in the SWAMP-in-a-Box Administrator Manual][4].

[1]: https://platform.swampinabox.org/siab-latest-release/administrator_manual.html#system-requirements
[2]: https://raw.githubusercontent.com/mirswamp/deployment/master/swampinabox/distribution/util/download-latest-swampinabox.bash
[3]: https://platform.swampinabox.org/siab-latest-release
[4]: https://platform.swampinabox.org/siab-latest-release/administrator_manual.html#installing-sib


## Documentation

* [SWAMP-in-a-Box Administrator Manual][10] ([pdf][11]):
  How to install, configure, and maintain SWAMP-in-a-Box.

* [SWAMP-in-a-Box Reference Manual][12] ([pdf][13]):
  Details of SWAMP-in-a-Box's configuration files and file system.

Copies of these manuals can be found in `/opt/swamp/doc` on the host after
SWAMP-in-a-Box has been installed.

[10]: https://platform.swampinabox.org/siab-latest-release/administrator_manual.html
[11]: https://platform.swampinabox.org/siab-latest-release/administrator_manual.pdf
[12]: https://platform.swampinabox.org/siab-latest-release/reference_manual.html
[13]: https://platform.swampinabox.org/siab-latest-release/reference_manual.pdf


## Source Code

The SWAMP's source code is contained in the following repositories:

- [db](https://github.com/mirswamp/db)
- [deployment](https://github.com/mirswamp/deployment)
- [services](https://github.com/mirswamp/services)
- [swamp-web-server](https://github.com/mirswamp/swamp-web-server)
  (includes customized [Laravel](https://laravel.com/) framework code)
- [www-front-end](https://github.com/mirswamp/www-front-end)

Additional supporting code is contained in the following repositories:

- [c-assess](https://github.com/mirswamp/c-assess)
- [java-assess](https://github.com/mirswamp/java-assess)
- [ruby-assess](https://github.com/mirswamp/ruby-assess)
- [script-assess](https://github.com/mirswamp/script-assess)
- [resultparser](https://github.com/mirswamp/resultparser)


----------------------------------------------------------------------------

## About the SWAMP

The Software Assurance Marketplace (SWAMP) is a platform for running
software assurance tools on your code. It is a joint effort of four research
institutions -- the Morgridge Institute for Research, Indiana University,
the University of Illinois at Urbana-Champaign, and the University of
Wisconsin-Madison -- to advance the capabilities and increase the adoption
of software assurance technologies through an open continuous assurance
facility. The SWAMP originally went live in February 2014 as a web
application at <https://www.mir-swamp.org>, where it provides continuous
software assurance capabilities to developers and researchers.

The SWAMP project is funded by the Department of Homeland Security (DHS)
Science and Technology Directorate.
