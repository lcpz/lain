Lain
====

-------------------------------------------------
Layouts, widgets and utilities for Awesome WM 4.x
-------------------------------------------------

:Author: Luke Bonham <dada [at] archlinux [dot] info>
:Version: git
:License: GNU-GPL2_
:Source: https://github.com/copycat-killer/lain

Warning
-------

If you still have to use branch 3.5.x, you can refer to the commit 301faf5_, but be aware that it's no longer supported.

Description
-----------

Successor of awesome-vain_, this module provides alternative layouts, asynchronous widgets and utility functions for Awesome_ WM.

Read the wiki_ for all the info.

Contributions
-------------

Any contribution is welcome! Feel free to make a pull request.

Just make sure that:

- Your code fits with the general style of the module. In particular, you should use the same indentation pattern that the code uses, and also avoid adding space at the ends of lines.

- Your code its easy to understand, maintainable, and modularized. You should also avoid code duplication wherever possible by adding functions or using lain.helpers_. If something is unclear, and you can't write it in such a way that it will be clear, explain it with a comment.

- You test your changes before submitting to make sure that not only your code works, but did not break other parts of the module too!

- You eventually update ``wiki`` submodule with a thorough section.

Contributed widgets have to be put in ``widget/contrib``.

Screenshots
-----------

.. image:: http://i.imgur.com/8D9A7lW.png
.. image:: http://i.imgur.com/9Iv3OR3.png
.. image:: http://i.imgur.com/STCPcaJ.png

.. _GNU-GPL2: http://www.gnu.org/licenses/gpl-2.0.html
.. _301faf5: https://github.com/copycat-killer/lain/tree/301faf5370d045e94c9c344acb0fdac84a2f25a6
.. _awesome-vain: https://github.com/vain/awesome-vain
.. _Awesome: https://github.com/awesomeWM/awesome
.. _wiki: https://github.com/copycat-killer/lain/wiki
.. _lain.helpers: https://github.com/copycat-killer/lain/blob/master/helpers.lua
