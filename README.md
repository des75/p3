p3
=====

App can read real files by chunks(from priv dir), or generate random data blobs (to simulate big and unique files) and calculate their md5.

Usage
-----

    $ make run
    $ curl http://localhost:12080/1.jpg

Testing
-------

For load tests `ab` tool is used, in combination with https://github.com/juanluisbaptiste/apachebench-graphs .
Some results can be found in `results` dir.

Build
-----

    $ make compile

Run server
----------

    $ make run

Run tests
---------

    $ make test
