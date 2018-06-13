# Test Driven Development in Digital Services
## Why test driven development?
* Test driven development allows us to confidently and more quickly make changes to code.
* Test driven development helps us write more secure software with less bugs.
* Test driven development forces us to document our work making it easier for other developers to understand our code.
* The business case for test driven development is we improve security, increase reliability, and reduce the cost of future changes to software.
### Background Reading
1. Mike Bland - [Goto Fail, Heartbleed, and Unit Testing Culture](https://martinfowler.com/articles/testing-culture.html)
2. Mike Bland - [Large Scale Development Culture Change](http://goo.gl/TU2pii)
3. David Heinemeier Hanson - [TDD is dead. Long live testing.](http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html)
4. Sandi Metz - [The Magic Tricks of Testing](https://www.youtube.com/watch?v=URSWYvyc42M)
5. Myron Marston and Ian Dees - [Effective Testing with RSpec 3](https://pragprog.com/book/rspec3/effective-testing-with-rspec-3)
6. David Heinemeier Hanson - [Testing like the TSA](https://signalvnoise.com/posts/3159-testing-like-the-tsa)

### Implementation
In order to implement test driven development we need to learn it within the constraints of both our projects and professional development budget. Given these limitations it is difficult to jump all in. However we can likely work towards implementing test driven development in our work. There are a few decision points:

1. What testing frameworks should we use? RSpec + Javascript testing framework.
2. In what order will we learn the things to learn in this new domain?
3. How rigorously should we adhere to TDD? Can we phase it in? Do we need to do it in all projects?
4. How do we want to learn it?

My idea is we use peer learning community as a model. Several folks recommended that Thoughtbot has an immersive 3 day course we can look into trying to take but they also offer [an online version of this course](https://thoughtbot.com/upcase/fundamentals-of-tdd) for $29/month subscription on their Upcase website. We can parcel out time together to watch the videos and discuss them. The video lectures can build the foundational theory and then we can start to try and implement specific tests and testing frameworks together on a per project basis.

### Some interesting perspectives

[Kent Beck](https://stackoverflow.com/questions/153234/how-deep-are-your-unit-tests/153565#153565):
> I get paid for code that works, not for tests, so my philosophy is to test as little as possible to reach a given level of confidence (I suspect this level of confidence is high compared to industry standards, but that could just be hubris). If I don't typically make a kind of mistake (like setting the wrong variables in a constructor), I don't test for it. I do tend to make sense of test errors, so I'm extra careful when I have logic with complicated conditionals. When coding on a team, I modify my strategy to carefully test code that we, collectively, tend to get wrong.

### Google Practices
1. Test Mercenaries that provided help
2. Testing on the toilet

>Teams were largely able to take responsibility for their own quality assurance, thanks in no small part to increased adoption of automated developer testing. What limited manual testing resources were available were well-utilized, because most potential quality issues were halted upstream by developer testing.

>While black-box testing (i.e. client-side testing with no knowledge of the internals of the code under test) can prove valuable, the concept that testing should only be a black-box process at the very end of development is a wasteful perspective. Why wait for a manual tester to catch a defect days, weeks, or months after it was introduced, when a unit test could have caught it before the original developer submitted the code?

>Teams were largely able to take responsibility for their own quality assurance, thanks in no small part to increased adoption of automated developer testing. What limited manual testing resources were available were well-utilized, because most potential quality issues were halted upstream by developer testing.

## 06-13-2018 Meeting Notes
* A question we often get is "why did you write bugs in the first place?"
* "Many bugs are like the suspension on the car. Even if it does not work, the wheels still turn and you still get to your destination." - Eric
* Part of this is on us to scope our estimates better and to include testing in that scope. Explain that error free code requires more effort than code of the past.
* Why do tests help reduce bugs? It is like writing down the terms and conditions in a contract. You do not rent an apartment by signing a document that simply says "I hereby rent this apartment." Instead you get a document that outlines details and nuance like who is responsible for replacing the lightbulbs.
* Folks were not excited about an immersive experience so we will probably not do this. Eric prefers books and working through tutorials and integrating into his own project work. Ian is going to investigate to decide whether asking for videos are worth it.