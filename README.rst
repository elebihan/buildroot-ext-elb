================================
Buildroot External Configuration
================================

This is a collection of various personal demo/test board configurations to be
used with Buildroot via the $BR2_EXTERNAL mechanism.

Usage
=====

To build configuration 'foo' proceed as follow::

  $ git clone https://github.com/elebihan/buildroot-ext-elb
  $ cd /path/to/buildroot
  $ make BR2_EXTERNAL=/path/to/buildroot-ext-elb foo_defconfig
  $ make
