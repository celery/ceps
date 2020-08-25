=========================
CEP XXXX: Feature Roadmap
=========================

:CEP: XXXX
:Author: Omer Katz
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Informational
:Created: 2020-08-25
:Last-Modified: 2020-08-25

.. contents:: Table of Contents
   :depth: 3
   :local:

.. role:: breaking-change
.. role:: new-feature

Abstract
========

This CEP details the roadmap for planned new features and breaking changes for Celery NextGen.
The description of these features is done in other CEPs. If one is available, we will provide a link to the matching CEP.
Otherwise, we will link to an issue which describes the motivation behind the feature or breaking change.

The document will be updated from time to time whenever we intend to release new major versions of Celery.

Specification
=============

Celery 5.x
-----------

Celery 5.0 is the first version to only support Python 3.

Breaking Changes
~~~~~~~~~~~~~~~~

- :breaking-change:`Drop support for Python 2.7.`
- :breaking-change:`Drop support for Python 3.5.`
- :breaking-change:`Drop support for the Riak result backend.`
- :breaking-change:`Drop support for librabbitmq.`

New Features
~~~~~~~~~~~~

- :new-feature:`New CLI based on Click.`

Celery 6.x
-----------

Celery 6.0 will introduce a new event loop, drop support for the prefork, gevent & eventlet worker pools
and will allow executing tasks defined with `async def` among other features.

Support for a single consumer and multiple workers will be reinstated in 7.x.

Breaking Changes
~~~~~~~~~~~~~~~~

- :breaking-change:`Drop support for the prefork workers pool.`
- :breaking-change:`Drop support for the gevent workers pool.`
- :breaking-change:`Drop support for the event workers pool.`
- :breaking-change:`Drop custom event loop.`
- :breaking-change:`Drop support for Redis < 5.0.0 as a message broker.`

New Features
~~~~~~~~~~~~

- :new-feature:`New Redis message broker implementation using Redis streams.`
- :new-feature:`Worker is now completely asynchronous.`
- :new-feature:`Users can now define and execute asynchronous tasks.`

Celery 7.x
-----------

Breaking Changes
~~~~~~~~~~~~~~~~

New Features
~~~~~~~~~~~~

- :new-feature:`Router`

Motivation
==========

We'd like to inform our users on which features will be released in the upcoming major versions of Celery.

In addition, we would like to communicate to our technical board what's in store for Celery.
We will create Github projects for each feature detailed in this CEP after it is accepted.

Rationale
=========

Backwards Compatibility
=======================

There are no backwards compatibility concerns in this CEP.

Reference Implementation
========================

There is no code or implementation involved in this CEP.

Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).

(All CEPs must include this exact copyright statement.)
