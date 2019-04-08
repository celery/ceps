==========================================
CEP XXXX: Celery 5 High Level Architecture
==========================================

:CEP: XXXX
:Author: Omer Katz
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Informational
:Created: 2019-04-08
:Last-Modified: 2019-04-08

.. contents:: Table of Contents
   :depth: 3
   :local:

Abstract
========

When Celery was conceived, production environments were radically different from today.

Nowdays most applications are (or should be):

* Deployed to a cloud provider's computing resources.
* Distributed, sometimes between datacenters.
* Failure reselient and Fault Tolerant.
* Observable.
* Built with scalibility in mind.
* Cloud Native - The application's lifecycle is managed using Kubernetes, Swarm or any other scheudler.

In addition, Celery lacks proper support for large scale deployments and some very useful messaging architectual patterns.

Celery 5 is the next major version of Celery and so we are able to break backwards compatibility, even in major ways.

As such, our next major version should represent a paradigm shift in the way we implement our task execution platform.

Specification
=============

This section should contain a complete, detailed technical specification should
describe the syntax and semantics of any new feature.  The specification should
be detailed enough to allow implementation -- that is, developers other than the
author should (given the right experience) be able to independently implement
the feature, given only the CEP.

Motivation
==========

This section should explain *why* this CEP is needed. The motivation is critical
for CEPs that want to add substantial new features or materially refactor
existing ones.  It should clearly explain why the existing solutions are
inadequate to address the problem that the CEP solves.  CEP submissions without
sufficient motivation may be rejected outright.

Rationale
=========

This section should flesh out out the specification by describing what motivated
the specific design design and why particular design decisions were made.  It
should describe alternate designs that were considered and related work.

The rationale should provide evidence of consensus within the community and
discuss important objections or concerns raised during discussion.

Backwards Compatibility
=======================

If this CEP introduces backwards incompatibilities, you must must include this
section. It should describe these incompatibilities and their severity, and what
mitigation you plan to take to deal with these incompatibilities.

Reference Implementation
========================

If there's an implementation of the feature under discussion in this CEP,
this section should include or link to that implementation and provide any
notes about installing/using/trying out the implementation.

Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (http://creativecommons.org/publicdomain/zero/1.0/deed).

(All CEPs must include this exact copyright statement.)
