# Contributing to Capybara

Thank you for your interest in contributing to Capybara. We are building this
software together and with your help it can become even better. Our time is
limited though, and if you follow these guidelines, you will make it much
easier for us to give feedback, help you find whatever problem you have and fix
it.

## Issues

If you have questions of any kind, or are unsure of how something works, please
ask on the [mailing list][list]. It can take us a while to get to new issues,
so a response on the mailing list will usually be quicker. Remember that
Capybara has a huge test suite and is used by thousands of people. It is far
more likely that there is an error in your code, and not a bug in Capybara. For
our own sanity we are merciless in closing issues where we feel that you
haven't shown that the issue really is within Capybara.

If you have identified a bug you can file it at the [issue tracker][tracker].
It would be very helpful if you could include a way to replicate the bug.
Ideally a failing test would be perfect, but even a simple script demonstrating
the error would suffice. Please don't send us an entire application, unless the
bug is in the *interaction* between Capybara and a particular framework.

Feature requests are great, but they usually end up lying around the issue
tracker indefinitely. Sending a pull request is a much better way of getting a
particular feature into Capybara. A good first step is to send your feature
request to the mailing list and see if anyone is interested in it, and get some
discussion going.

## Patches

Capybara is a testing framework, as such, the requirements for patches are a
bit tougher than for normal libraries. If you want your patches to be accepted,
please follow the following guidelines:

- *Add tests!* Your patch won't be accepted if it doesn't have tests.

- *Document any change in behaviour*. Make sure the README and any other
  relevant documentation are kept up-to-date.

- *Consider our release cycle*. We try to follow semver. Randomly breaking
  public APIs is not an option.

- *Create topic branches*. Don't ask us to pull from your master branch.

- *One pull request per feature*. If you want to do more than one thing, send
  multiple pull requests.

- *Send coherent history*. Make sure each individual commit in your pull
  request is meaningful. If you had to make multiple intermediate commits while
  developing, please squash them before sending them to us.

- *Follow coding conventions*. The standard Ruby stuff, two spaces indent,
  don't omit parens unless you have a good reason.

Thank you so much for contributing!

[list]: http://groups.google.com/group/ruby-capybara
[tracker]: http://github.com/jnicklas/capybara/issues
