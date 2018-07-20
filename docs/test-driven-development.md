# Software Testing in Digital Services
## Why automated software testing?
* Automated software testing allows us to confidently and more quickly make changes to code.
* Automated software testing helps us write more secure software with less bugs.
* Automated software testing forces us to document our work making it easier for other developers to understand our code.
* The business case for automated software testing is we improve security, increase reliability, and reduce the cost of future changes to software.

## Background Reading
1. Mike Bland - [Goto Fail, Heartbleed, and Unit Testing Culture](https://martinfowler.com/articles/testing-culture.html)
2. Mike Bland - [Large Scale Development Culture Change](http://goo.gl/TU2pii)
3. David Heinemeier Hanson - [TDD is dead. Long live testing.](http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html)
4. Sandi Metz - [The Magic Tricks of Testing](https://www.youtube.com/watch?v=URSWYvyc42M)
5. Myron Marston and Ian Dees - [Effective Testing with RSpec 3](https://pragprog.com/book/rspec3/effective-testing-with-rspec-3)
6. David Heinemeier Hanson - [Testing like the TSA](https://signalvnoise.com/posts/3159-testing-like-the-tsa)

## Implementation
In order to implement automated we need to learn it within the constraints of both our projects and professional development budget. Given these limitations it is difficult to jump all in. However we can work towards implementing automated testing in our work.

We have decided that for Ruby on Rails projects we will use [RSpec](http://rspec.info) and for React/Javascript projects we will generally use [Jest](https://facebook.github.io/jest/). Ember projects will be tested using [QUnit](https://guides.emberjs.com/release/testing/).

Automated testing may not be necessary for simple static websites so we are going to aim towards implementing it in [MassBuilds](https://github.com/MAPC/massbuilds) first.

We need to communicate the value of automated testing and include it in our estimates when we do issue review.

We need to mutually reinforce the need for tests when we do pull request review.


