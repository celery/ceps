.. vale off

===================
CEP XXXX: Publisher
===================

:CEP: XXXX
:Author: Omer Katz
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Feature
:Created: 2019-04-03
:Last-Modified: 2019-04-03

.. contents:: Table of Contents
   :depth: 3
   :local:

This CEP provides a sample template for creating your own CEPs.  In conjunction
with the content guidelines in :doc:`/final/0001-cep-process`,
this should make it easy for you to conform your own CEPs to the format
outlined below.

Note: if you are reading this CEP via the web, you should first grab `the source
of this CEP <https://raw.githubusercontent.com/celery/ceps/master/template.rst>`_ in
order to complete the steps below.  **DO NOT USE THE HTML FILE AS YOUR
TEMPLATE!**

To get the source this (or any) CEP, look at the top of the Github page
and click "raw".

If you're unfamiliar with reStructuredText (the format required of CEPs),
see these resources:

* `A ReStructuredText Primer`__, a gentle introduction.
* `Quick reStructuredText`__, a users' quick reference.
* `reStructuredText Markup Specification`__, the final authority.

__ http://docutils.sourceforge.net/docs/user/rst/quickstart.html
__ http://docutils.sourceforge.net/docs/user/rst/quickref.html
__ http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html

Once you've made a copy of this template, remove this abstract, fill out the
metadata above and the sections below, then submit the CEP. Follow the
guidelines in :doc:`/final/0001-cep-process`.

Abstract
========

This should be a short (~200 word) description of the technical issue being
addressed.

This (and the above metadata) is the only section strictly required to submit a
draft CEP; the following sections can be barebones and fleshed out as you work
through the CEP process.

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

This section should flesh out the specification by describing what motivated
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
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).

(All CEPs must include this exact copyright statement.)
