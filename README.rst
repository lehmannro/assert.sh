###########
 assert.sh
###########

**assert.sh** is test-driven development in the Bourne again shell.

This repository is forked from [here](https://raw.github.com/lehmannro/assert.sh).

.. image:: https://github.com/nrnrk/assert.sh/actions/workflows/bash.yml/badge.svg
   :target: https://github.com/nrnrk/assert.sh/actions

Example
=======

::

  . assert.sh

  # `echo test` is expected to write "test" on stdout
  assert "echo test" "test"
  # `seq 3` is expected to print "1", "2" and "3" on different lines
  assert "seq 3" "1\n2\n3"
  # exit code of `true` is expected to be 0
  assert_raises "true"
  # exit code of `false` is expected to be 1
  assert_raises "false" 1
  # end of test suite
  assert_end examples

If you had written the above snippet into ``tests.sh`` you could invoke it
without any extra hassle::

  $ ./tests.sh
  all 4 examples tests passed in 0.014s.

Watch out to have ``tests.sh`` executable (``chmod +x tests.sh``), otherwise
you need to invoke it with ``bash tests.sh``.

Now, we will add a failing test case to our suite::

  # expect `exit 127` to terminate with code 128
  assert_raises "exit 127" 128

Remember to insert test cases before ``assert_end`` (or write another
``assert_end`` to the end of your file). Otherwise test statistics will be
omitted.

When run, the output is::

  test #5 "exit 127" failed:
          program terminated with code 127 instead of 128
  1 of 5 examples tests failed in 0.019s.

The overall status code is 1 (except if you modified the exit code manually)::

  $ bash tests.sh
  ...
  $ echo $?
  1

Features
========

+ lightweight interface: ``assert`` and ``assert_raises`` *only*
+ minimal setup -- source ``assert.sh`` and you're done
+ test grouping in individual suites
+ time benchmarks with real-time display of test progress
+ run all tests, stop on first failure, or collect numbers only
+ automatically set the exit status of the test script
+ skip individual tests

Use case
========

You wrote an application. Following sane development practices, you want to
protect yourself against introducing errors with a test suite. Even though most
languages have excellent testing tools, modifying process state (input ``stdin``,
command line arguments ``argv``, environment variables) is awkard in most
languages. The shell was made to do just that, so why don't run the tests in
your shell?

Installation
============

You can easily install the latest release (or any other version)::

  wget https://raw.github.com/lehmannro/assert.sh/v1.1/assert.sh

Use the following command to grab a snapshot of the current development
version::

  wget https://raw.github.com/lehmannro/assert.sh/master/assert.sh

There is no additional build/compile step except for changing permissions
(``chmod +x``) depending on the way you have chosen to install *assert.sh*.

bpkg
----

The ``bpkg`` package manager allows you to install *assert.sh* locally::

  bpkg install lehmannro/assert.sh

(Watch out to ``source deps/assert/assert.sh`` instead.)

If you want to install globally, for your whole system, use::

  bpkg install lehmannro/assert.sh -g

Reference
=========

+ ``assert <command> [stdout] [stdin]``

  Check for an expected output when running your command. `stdout` supports all
  control sequences ``echo -e`` interprets, eg. ``\n`` for a newline. The
  default `stdout` is assumed to be empty.

+ ``assert_raises <command> [exitcode] [stdin]``

  Verify `command` terminated with the expected status code. The default
  `exitcode` is assumed to be 0.

+ ``assert_end [suite]``

  Finalize a test suite and print statistics.

+ ``skip``

  Unconditionally skip the following test case.  The skipped test case is
  *exempt* from any test diagnostics (ie., not accounted for in the total
  number of tests.)

+ ``skip_if <command>``

  Skip the following test case if `command` exits successfully.  (``skip``
  disclaimer applies.)  Use this if you want to run a test only if some
  precondition is met, eg. the test needs root privileges or network access.

Command line options
--------------------

See ``assert.sh --help`` for command line options on test runners.

  -v, --verbose    Generate real-time output for every individual test run.
  -x, --stop       Stop running tests after the first failure.
                   (Default: run all tests.)
  -i, --invariant  Do not measure runtime for suites. Useful mainly to parse
                   test output.
  -d, --discover   Collect test suites and number of tests only; don't run any
                   tests.
  -c, --continue   Do not modify exit code depending on overall suite status.
  -h               Show brief usage information and exit.
  --help           Show usage manual and exit.

Environment variables
---------------------

================= ====================
variable          corresponding option
================= ====================
``$DEBUG``        ``--verbose``
``$STOP``         ``--stop``
``$INVARIANT``    ``--invariant``
``$DISCOVERONLY`` ``--discover-only``
``$CONTINUE``     ``--continue``
================= ====================

Changelog
=========

1.1
  * Added ``skip`` and ``skip_if`` commands.
  * Added support for ``set -e`` environments (closes `#6
    <https://github.com/lehmannro/assert.sh/pull/6>`_, thanks David Schoen.)
  * Modified exit code automatically in case *any* test failed in the suite.
  * Added ``--continue`` flag to avoid tinkering with the exit code.
  * Removed ``bc`` dependency (closes `#8
    <https://github.com/lehmannro/assert.sh/issues/8>`_, thanks Maciej Żok.)
  * Added installation instructions for `bpkg <http://bpkg.io/>`_ (closes `#9
    <https://github.com/lehmannro/assert.sh/pull/9>`_, thanks Joseph Werle.)

1.0.2
  * Fixed Mac OS compatibility (closes `#3
    <https://github.com/lehmannro/assert.sh/issues/3>`_.)

1.0.1
  * Added support for ``set -u`` environments (closes `#1
    <https://github.com/lehmannro/assert.sh/issues/1>`_.)
  * Fixed several leaks of stderr.
  * Fixed propagation of options to nested test suites.

Related projects
================

`Advanced Bash-Scripting Guide`__
  An in-depth exploration of the art of shell scripting by The Linux
  Documentation Project proposes a mechanism inspired by C, similar to
  *assert.sh*.

__ http://www.tldp.org/LDP/abs/html/debugging.html

`ShUnit`__
  ShUnit is a testing framework of the xUnit family for Bourne derived shells.
  It is quite feature-rich but requires a whole lot of boilerplate to write a
  basic test suite.  *assert.sh* aims to be lightweight and easy to setup.

__ http://shunit.sourceforge.net/

`shUnit2`__
  shUnit2 is a modern xUnit-style testing framework. It comes with a bunch of
  magic to remove unneccessary verbosity. It requires extra care when crafting
  test cases with many subprocess invocations as you have to fall back to shell
  features to fetch results.  *assert.sh* wraps this functionality out of the
  box.

__ http://code.google.com/p/shunit2/

`tap-functions`__
  A Test Anything Protocol (TAP) producer with an inherently natural-language-
  style API.  Unfortunately it's only of draft quality and decouples the test
  runner from analysis, which does not allow for *assert.sh* features such as
  ``--collect-only`` and ``--stop``.

__ http://testanything.org/wiki/index.php/Tap-functions

`bats`__
  Another TAP producer with syntactic sugar.  It depends on ``errexit``
  environments (set -e) to run its tests such that *"each line is an assertion
  of truth."*

__ https://github.com/sstephenson/bats

`stub.sh`__
  Helpers to fake binaries and bash builtins. It supports mocking features such
  as expecting a certain number of invocations and plays well with *assert.sh*.

__ https://github.com/jimeh/stub.sh
