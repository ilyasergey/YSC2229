.. -*- mode: rst -*-

Installing and using Git
========================

We will be using ``git`` as a version control for this course. You will have to master a small set of its commands to be able to submit your homework assignments.

Command-line client for ``git`` comes as a part of standard macOS and Linux distributions, but you can install is separately via ``apt`` or ``brew``. Please, also create yourself an account on `GitHub <http://github.com/>`_, as you will need it to make submissions.

To work with GitHub comfortably, you will need to set up your SSH keys. To do so, run the following command in your terminal (entering your email)::

  ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

After that, run ``cat ~/.ssh/id_rsa.pub`` and copy all the text starting with ``ssh-rsa`` and ending with your email.
 
Follow `these instructions <https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account>`_ to add this text as your public SSH key to your GitHub entry.

Finally, execute the following commands from terminal, providing your email address and name correspondingly::

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

These quick tutorials should be helpful in learning basic commands of working with Git:

* `Git basics <https://www.freecodecamp.org/news/learn-the-basics-of-git-in-under-10-minutes-da548267cc91/>`_
* `Git cheat sheet <https://github.github.com/training-kit/downloads/github-git-cheat-sheet.pdf>`_

Don't worry - you will have plenty of opportunity to master this knowledge during the course!

Finally, please consider applying for student benefits on GitHub. This is totally free and will give allow you to make the best of your GitHub account. The instructions on how to apply can be `found online <https://education.github.com/pack>`_.







