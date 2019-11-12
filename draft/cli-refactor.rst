======================
CEP XXXX: CLI Refactor
======================

:CEP: XXXX
:Author: Omer Katz
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Feature
:Created: 2019-11-10
:Last-Modified: 2019-11-10

.. contents:: Table of Contents
   :depth: 3
   :local:

Abstract
========

Celery's CLI infrastructure is based on a custom framework built using the :mod:`argparse` built-in module.
This implementation has multiple design defects and a few bugs and as a result a developer cannot easily read the code
or extend it.

As we're moving towards Celery 5, we are likely to add new sub-commands and/or enhance existing ones.
Therefore, refactoring this part of the codebase will increase our future productivity and flexibility.

This CEP proposes to refactor our CLI implementation in order to make that part of the code developer friendly
and user extensible.

Specification
=============

The refactor replaces our custom :mod:`argparse` framework which can be found `here <https://github.com/celery/celery/tree/dc03b6d342a8008d123c97cb889d19add485f8a2/celery/bin>`_
with an implementation using Click_.

CLI Context
-----------

Instead of sharing common functionality in the `Command` base class we introduce a class called :class:`CLIContext`
which provides access the Celery application, helper methods for printing informational messages or errors
and other common functionality.

Parameter Types
---------------

The current implementation extracted common parsing and validation code of parameter types into
`custom types <https://click.palletsprojects.com/en/7.x/parameters/#implementing-custom-types>`_ which can be reused
across our CLI implementation.

Plugins
-------

Motivation
==========

The main purpose of this refactor is to allow us to use an event loop using Python 3's `async/await` syntax
without investing further in our custom CLI framework.
Instead we opt to use a battle-tested solution which allows us to remove the entire custom framework entirely.

This allows us to delegate the maintenance overhead to others and reduce the surface of potential bugs introduced in
Celery 5.

In addition, the ecosystem provides us with many features that argparse lacks such as `"Did you mean" <https://github.com/click-contrib/click-didyoumean>`_ messages,
`automatic documentation <https://github.com/click-contrib/sphinx-click>`_ using Sphinx and other user experience
enhancing features which :mod:`argparse` lacks.

Rationale
=========

Alternative CLI Frameworks
--------------------------

Docopt was considered as part of this effort but was found insufficient for our needs.

Parameter Types
---------------

Our previous implementation used to parse and validate some of the arguments during the actual execution of the command.
No infrastructure was provided to share the implementation of parsing and validating such special arguments such as
ISO-8601 date time strings or comma separated lists.

This resulted in violation of the `DRY <https://en.wikipedia.org/wiki/Don%27t_repeat_yourself>`_ principle and
more importantly the `Single Responsibility Principle (SRP) <https://en.wikipedia.org/wiki/Single_responsibility_principle>`_.

Violating SRP makes unit testing harder as there are more code paths to take care of.
This violation also increases the difficulty of reasoning about the code in question for the same reason.

The current implementation separates the responsibility of parsing and validating arguments from the command invocation
itself to small classes which are very easy to unit test and reason about.

Backwards Compatibility
=======================

This CEP is almost completely backwards compatible with our previous implementation.

The only changes in our API are around the CLI's customization.

User Options
------------

Preload Options
---------------

Reference Implementation
========================

The reference implementation can be found at `celery/celery#5718 <https://github.com/celery/celery/pull/5718>`_.

Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).

(All CEPs must include this exact copyright statement.)

.. _Click: https://click.palletsprojects.com/