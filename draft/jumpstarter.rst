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

`Next-Gen Celery`_ aims to:

1. Move Celery from the past to the present. 

2. Resolve long-standing design bugs in our implementation. 

3. Modernize the code to use the all latest Python 3+ idioms and best practices. 

4. Do a number of other things not entirely in the scope of this document (see `Next Gen Rationale`_). 

Before work is to begin on this next generation of Celery, it's crucial to have
a discussion about and carve out the building blocks that will form the
primitives for the upcoming Celery. These building blocks should fulfill 1, 2,
and 3 (especially) above, and also help fulfill the goals from the linked
`Next-Gen Rationale`_.

For Celery to move forward into the modern age, and the future of computing
with increasingly decentralized systems, it's important for Celery to follow a
standardized asynchronous execution model. Namely, we want to define things
like: 

1. How does Celery interact with itself (its own internal components)? 

2. How does Celery interact with others (and how do others interact with it)? 

3. How do Celery's internal components interact with each other and their outside environment? 

Also, we want Celery to work with the emerging and maturing asynchronous python
landscape.  Celery is *very asynchronous* by nature, dealing with brokers,
queues, results, timeouts, chord-like joins, task groups, you name it.
Modern asynchronous python frameworks have provided new, innovative, and robust
solutions to many things that overlap with Celery's goals.

To do all of this, we propose modeling next-gen Celery off of the `Actor Model`_. Namely,
we propose that the Celery Worker will be modeled as an `Actor System`_ of sorts.

By the end of this initial implementation, we should have a proposal and reference implementation that: 

1. Models Tasks and other key Celery primitives (some to be implemented and
further specced-out down the line) as Actors. 

2. Can give a clear overview about how these various Celery primitives (as
Actors) communicate with each other and pass messages (referencing the Actor
model). 

3. Can enable the development of a future version of Celery where it can be run
embedded with ``async/await`` (if desired by the programmer, not necessary),
and can have synchronous-friendly workers and asynchronous-friendsly/purely
asynchronous workers. 


Specification
=============

TODO

This section should contain a complete, detailed technical specification should
describe the syntax and semantics of any new feature.  The specification should
be detailed enough to allow implementation -- that is, developers other than the
author should (given the right experience) be able to independently implement
the feature, given only the CEP.

Motivation
==========

TODO (WIP)

This section should explain *why* this CEP is needed. The motivation is critical
for CEPs that want to add substantial new features or materially refactor
existing ones.  It should clearly explain why the existing solutions are
inadequate to address the problem that the CEP solves.  CEP submissions without
sufficient motivation may be rejected outright.

Let's start with an example, and then generalize. A quick search in Celery's
GitHub issue tracker for `chord
<https://github.com/celery/celery/issues?q=is%3Aissue+is%3Aopen+chord>`_ shows
a many issues. A number of them (of which some have been fixed) involve complex
cases involving non-trivial Celery workflows. While fixes have been released
over time as these have come up, many issues stand unresolved to this day. The
Celery team could continue to try and fix these issues, or we could take a look
back and think about how we want to design Celery for the future. although
there have been a number of difficulties with getting started on fixing these
issues in the first place! I'll try and list some of what I see these to be:

1. Celery has had to support, for a long time, both Python 2 and Python 3.
While the codebase has been modernized to a degree with Python 3 nowadays, it
wasn't originally conceived or written that way. It was built back in the
Python 2 days, and had (and still continues to have), a number of features and
ideas. It was (and still is), incredibly pluggible, and supports a number of
use cases and very high throughout if configured correctly. However, Python as
a language has changed significantly in the last 10 years. Namely, proper
support for coroutines in the form of `async/await`. 

2. Celery, as a whole, involves a number of different working parts that are
integrated together. In the current scheme of things, we have workers, brokers,
result stores, workflows (``canvas`` primitives), rate limiting, policies,
signatures, settings, periodic tasks, scheduling, ..., and many other things.
Many of the primitives for these integrated parts were built almost a decade
ago, when both the language landscape (as mentioned above), but also the
*library landscape* was quite a bit different than today. Celery came with a
custom CLI parser, custom event loop implementation (which it still has at the
time of writing), and support for a number of other things that are today
implemented in multiple different solid third party libraries. 

3. Given the complexity of the mentioned issues, it's not easy to get to the
root cause of what's happening in the first place. Because Celery is very
*asynchronous* by nature, many of the tests are wrapped with a ``flaky``
decorator which means, sometimes (depending on the arrival of messages, speed
of IPC, speed of the network, and many other factors), maybe the test won't
pass in an expected amount of time or might not always succeed. Testing and
modeling asynchronous processes is definitely not easy, but the python
language, tooling, and libraries have evolved considerably in the last
*decade*, and Celery is well positioned for a large restructuring that allows
it both internally take advantage of the latest Python features, and also
provide external integration with them as well. 

With all of these mentioned, and given the chord example, again, we could
continue to try and improve and fix things as is, or we could take a step back
and reflect as to *why* there are so many subleties and quirks with the
implementation. I think one of the ultimate reasons boils down to a lack of
simplicity. In Celery, certain aspects of the codebase are responsible for
a number of things...

^ TODO: I want to elborate on this more, but I'm not sure if it's appropriate.
I think the Actor Model and modeling the worker as an Actor System gives us a
number of benefits, which I want to succintly summarize in the beginning and
give a lot more detail as a part of the CEP. Specifically, I'd like to
explain/say why modeling things as an Actor system will make Celery a lot
easier to reason about, maintain, and add new, for example, Canvas primitives
to (or even re-build/design them, etc. if that's something that's desired).
There are clear advantages to keeping state internal to the worker, for
example, adding cancel groups, and other things that make some of the more
asynchronous parts of Celery easier to work with, test, and reason about. The
main thing also, though, is to really separate concerns and responsibilities.
It *seems* to me that some of the current Celery code is not very SRP, in the
sense that it's responsible for calling code at a number of different layers
and doing a number of complex things. With the actor system, each actor gets a
lot more specialized and I think that makes the implementation a lot easier to
both reason about and extend.  Composition (vs., for example, inheritance
currently present with ``Signature`` objects for example to then create the
canvas objects) then becomes a lot more attractive and possible.  To give an
example, a ``chord`` then simply becomes responsible for passing a message to
the underlying ``Task`` (s) or ``result`` (s) (to define more) that would
essentially make them then send off another "message" (we'll call it right now)
or messages to other components in the actor system that are then responsible
for handling that message (think of ``on_chord_part_return`` here).



Rationale
=========

TODO

This section should flesh out the specification by describing what motivated
the specific design design and why particular design decisions were made.  It
should describe alternate designs that were considered and related work.

The rationale should provide evidence of consensus within the community and
discuss important objections or concerns raised during discussion.

Backwards Compatibility
=======================

TODO

If this CEP introduces backwards incompatibilities, you must must include this
section. It should describe these incompatibilities and their severity, and what
mitigation you plan to take to deal with these incompatibilities.

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
