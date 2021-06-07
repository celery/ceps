.. vale off

======================
CEP XXXX: Jumpstarter
======================

:CEP: XXXX
:Author: Micah Lyle
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Feature
:Created: 2021-05-09
:Last-Modified: 2021-05-09

.. contents:: Table of Contents
   :depth: 3
   :local:

Abstract
========

Since Celery was conceived over a decade ago, the Python landscape has evolved
considerably. Of the key recent developments has been the introduction and successive
improvements of Python's ``async/await`` support, with the growing ecosystem surrounding
its asynchronous/concurrent programming paradigm.

When Celery was initially built, it was very innovative and forward/future-thinking for its time.
It had (and still has) its own event loop implementation, and supported top-of-the-line
asynchronous programming models of the time, such as ``gevent`` and ``eventlet``.

Enter the start of the 2020s decade and Python, along with its ``async/await`` ecosystem
has been rapidly growing and thriving, providing a number of advancements improving
Python's asynchronous/concurrent programming model.

Currently, Celery does not natively support ``async/await``, either with queueing or
waiting on the result of tasks, like ``await some_task.apply_async(...)``, nor the usage
of ``async def`` and ``await`` from within tasks themselves. For example, without using
some custom written code of your own or a newer community-supported project like
`Celery Pool AsyncIO`_, you cannot define a task with ``async def`` nor can your task
(because it's not defined with ``async def``) do something like ``await
some_async_fn(...)`` unless within your task you booted up a modern ``async/await``
compatible event loop or used some other workaround.

That leads this CEP, whose purpose is to provide a foundational asynchronous programming
framework for the broader Python community modeled after the `Actor Model`_, and also
provide a foundation for `Next-Gen Celery`_ to be built upon. This will, down the line:

1. Allow awaiting on an asynchronous task results:

  .. code-block:: python

  await some_task.apply_async(args=(1,2), kwargs={"kwarg1": 3 })

2. Allow definining ``async`` tasks that can utilize ``await``, ``async with``, and all
the other features of Python's ``async/await`` programming model.

  .. code-block:: python

  @task
  async def my_task(...):
    x = await some_async_fn1(...)
    async with (...):
      y = await some_async_fn2(...)

Specification
=============

Motivation
==========

There are two primary motivations to discuss.

1. The motivation to build `Jumpstarter`_.

2. The motivation to, down the line, use `Jumpstarter`_ as a foundation for parts of
`Next-Gen Celery`_.

For the first motivation, one of Celery's main use cases is to build asynchronous,
distributed systems that communicate via message passing. The `Actor Model`_, which has
been around for almost half a century and is a tried and tested way to design and build
large-scale concurrent systems. It very much matches what Celery aims to do and has
shown to have great success in projects like `Akka`_ and many others. The `Actor Model`_
also works great with Python's ``async/await`` support as messages are able to be
asynchronously sent and awaited upon very efficiently.

`Jumpstarter`_ comes in to fill the spot of being that fundamental/primititve library to
build `Next-Gen Celery`_ on top of, while simultaneously being a modern implementation
and interpretation of the `Actor Model`_ (and an `Actor System`_, or at least blocks for
building one) in Python. For reasons why Celery would build its own library instead of
using an existing Actor framework in Python, see the :ref:`Rationale` below.

For the second motivation, certain bugs and issues in Celery resolve around things like
chord synchronization/counting errors, very hard to reproduce concurrency issues, canvas
edge cases, etc. Looking at these issues from a higher perspective and the current state
of the codebase, future versions of Celery could benefit from code that adheres to
something like the `Actor Model`_, which really helps to eliminate race conditions,
locking issues, shared state issues, and other things like that which are out of the
scope of this document.  Modeling workers, tasks, canvas primitives, and other Celery
components after an `Actor System`_ and making them hold to the fundamental axioms of
the `Actor Model`_ will encourage code that is far more Single Responsibility Principle
(SRP) than the current codebase is, and encourage both designs and implementations that
are easier to reason about, easier to test, and easier to extend and work with. The
design of various Celery components using `Jumpstarter`_ primitives is outside of the
scope of this document and would be addressed in future CEPs.

Rationale
=========

A quick internet search of Python actor libraries and packages returns a
few different results. Before listing some of those libraries, the main
reasons for building our own `Actor Model`_ implementation are as follows:

1. We want a framework that is built with and for ``async/await`` from the beginning, and
that takes advantage of all the latest abstractions and innovations in Python's
``async/await`` support and the latest general language features as well (like
``typing`` and other things). Many of the other frameworks listed below were built
either before ``async/await`` or in the earlier stages. 

2. We want something that can be a standalone framework, but that can _also_ be informed by
the needs of `Next-Gen Celery`_. Hence, we'd like for the Celery organization to
maintain and shepherd the project. We may find that we need to make changes rapidly in
the beginning, and we'd like to see the project evolve and grow quickly without being
blocked by other large dependent projects (like some or many of these other libraries
may be), especially in the beginning. By Celery creating a new library, we can both
enable rapid development of `Jumpstarter`_ and `Next-Gen Celery`_ now and down the line, while
still providing a framework that the greater Python community may find helpful to build
other projects off of.

With that being said, let's take a look at a few existing projects:

* `Pykka`_ is a Python-based actor that was extracted originally from `Mopidy`_, an "extensible music server written in Python". We wouldn't use `Pykka`_ for two main reasons:

  * It doesn't support ``async/await`` currently, and hasn't supported it from the beginning.
  * It powers `Mopidy`_, and probably a number of other significant projects rely on it to some extent, so it wouldn't make sense to rely upon it for reasons listed above.

* `Cell`_ was an earlier attempt at an actor model/framework for Celery. It wasn't very widely used and developed.

  * Given reason #1 above, it makes sense to archive `Cell`_ and move forward with `Jumpstarter`_ (`comment <https://github.com/celery/jumpstarter/issues/1#issuecomment-755347761>`_).

* `Thespian`_ is a very rich-featured "Python Actor concurrency library." Of all the libraries listed, it would seem the most promising for something to use and/or build off, of, except that:

  * It seems to have been built out before the early ``asyncio`` ``async/await`` phase of Python's development. The ``async/await`` syntax wasn't quite around yet, and libraries like `Curio`_ and `Trio`_ weren't around yet. Python's asynchronous programming model has come a long way since the 3.3/3.4 and early ``asyncio`` days. Along with reason #1 above, we really want to support some of the newer asynchronous ideas (and use them as a base) with `Jumpstarter`_. Given the large size of `Threspian`_'s codebase, it would be very seemingly impractical to try and tweak an aircraft carrier (metaphorically speaking) to fit our use cases.
  * The library seems to have been in maintenance mode for the last few years. It was originally built in house at GoDaddy, and the original author does not work there anymore.  Scanning the release history shows more maintenance releases than new activity, which, given its large size, possibly external large-project dependencies, and reason #2 above, makes us inclined to still build our own framework. That being said, there may be useful things that can be learned from `Threspian`_, whether high level structure or low level details.

* `Pulsar`_ is an "Event driven concurrent" framework for Python. It's goal, according to its README, "is to provide an easy way to build scalable network programs." It was built upon ``asyncio`` from the Python3.5+ days and supports ``async/await``. However, while it has a number of powerful and interesting features, it has been archived by its owner, so discussing it more does not feel necessary for the scope of this document.

  * Additionally, while it does seem to have great support for building generally network connected programs, a number of examples show how to use it to build something like a non-blocking ``wsgi`` server. Celery does intend to handle such use cases, especially given the development of the ``asgi`` specification, and many other modern libraries under current development that are doing a great job with ``asgi``. Similar to what was said about `Thespian`_, there may be useful things that can be learned from `Pulsar`_, but it's not something that we think should be built upon, for similar reasons to `Thespian`_ above, along with our general reasons #1 (``asyncio`` only would not satisfy that) and #2 (`Pulsar`_ seems to have been by and potentially for a group called `Quantmind <https://quantmind.com/>`_).

Backwards Compatibility
=======================

Given that `Jumpstarter`_ is a library being built from scratch, there isn't too much to
talk about on the backwards compatibility side of things. It's an open discussion at the
moment of we should support Python 3.7+ or Python 3.10+. It might be nice, given
``trio``, ``asyncio``, and other ``async/await``/event loop implementation improvements
in the last number of Python versions to rely on 3.10+. And on top of that, we'd get the
latest improvements in the ``typing`` world, and pattern matching that we could use from
the beginning.

Reference Implementation
========================

The `Reference Implementation`_ has a nice sketch of how actors might look in
`Jumpstarter`_. Some of the kinks and details are still being worked out, but
that's the place to go and start taking a look at the time of writing. Further
buildout of certain aspects of the reference implementation (which are also
related to `Celery Next-Gen`_) may be blocked or waiting on some third-party
library support. One example is we're waiting for an `APScheduler 4.0
Release`_.

Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).

(All CEPs must include this exact copyright statement.)

.. Next-Gen Celery https://github.com/celery/ceps/blob/master/draft/high-level-architecture.rst
.. Jumpstarter https://github.com/celery/jumpstarter
.. Reference Implementation https://github.com/celery/jumpstarter/tree/actor
.. AP Scheduler 4.0 Release https://github.com/agronholm/apscheduler/issues/465
.. Next-Gen Rationale https://github.com/celery/ceps/blob/master/draft/high-level-architecture.rst#rationale
.. Actor Model https://en.wikipedia.org/wiki/Actor_model
.. Actor System https://doc.akka.io/docs/akka/current/general/actor-systems.html
.. Celery Pool AsyncIO https://github.com/kai3341/celery-pool-asyncio
.. Akka https://akka.io/
.. Pykka https://github.com/jodal/pykka
.. Mopidy https://github.com/mopidy/mopidy
.. Cell https://github.com/celery/cell
.. Thespian https://github.com/thespianpy/Thespian
.. Pulsar https://github.com/quantmind/pulsar
.. Asyncio https://docs.python.org/3/library/asyncio.html
.. Curio https://github.com/dabeaz/curio
.. Trio https://github.com/python-trio/trio
.. Trio-Asyncio https://github.com/python-trio/trio-asyncio
