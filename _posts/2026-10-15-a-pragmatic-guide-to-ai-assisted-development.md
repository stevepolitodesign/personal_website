---
title: A pragmatic guide to AI-assisted development
excerpt: Learn how I use AI-assisted development to understand, ship, and verify a real fix.
category: ["Artificial Intelligence"]
tags: ["Artificial Intelligence", "Tutorial"]
canonical_url: https://thoughtbot.com/blog/a-pragmatic-guide-to-ai-assisted-development
---

I'm currently staffed on a project in a codebase I have no familiarity
with, so I've leaned on AI-assisted development more than ever. Along
the way, I've found that writing the code is the easy part. Most of my
time goes into understanding the problem, exploring solutions, and
verifying the output.

In this tutorial, I'll walk through each phase of my approach as I work
on a real issue. Feel free to follow along below, or browse the [skills]
I used.

## Our base

I'll be working on our internal scheduling tool, Hub. Hub allows
employees to set their experience and interest level for certain skills.
These are then rendered on an employee's profile and help us decide who
to staff on new opportunities.

The issue is that we feature certain skills in a "Highlighted abilities"
card, without accounting for the employee's interest level. So, an
employee who has Mentor-level experience with iOS development, but is
Very Opposed to that work, would still have the skill listed in the
"Highlighted abilities" card. As a result, one employee was picked up as
someone who might want to work on an iOS project, which was the last
thing he wanted.

For context, I used Claude Code in the Claude desktop app with Opus 5.5,
but the principles and approach will work across tooling and models.

## Make sure the agent can run the app

The first thing I do as part of my AI-assisted workflow is make sure the
LLM can [run the application][run-verify]. If it can't, it can't verify
its work. Plus, it saves me from having to deal with the paper cuts of
setting up the application myself. Here's the prompt I ran:

> I have not run this project in a long time. Can you use /run to spin
> it up? If you find that does not work, use subagents to figure out how
> to get the app running locally, and use /run-skill-generator to
> extract that into a skill.

The LLM probed the application until it was able to spin it up
successfully, and generated a `/run-hub` skill, which others can use
now.

![Claude Code session reporting Hub is running via the new /run-hub skill, next to the Hub dashboard open at localhost:3000](https://images.thoughtbot.com/f7n1y23v8f966xiv42rwiarbn04c_Screenshot%202026-09-29%20at%208.34.12%E2%80%AFPM.png)

## Understand the behavior, not the code

Although the problem was fairly straightforward, I wanted to slow down
and make sure I actually understood it before rushing to implement a fix
with an LLM.

### Load the issue in a new session

I started by loading the issue into context in a new session. This gives
the LLM everything it needs, including comments and screenshots.

> Load https://github.com/thoughtbot/hub/issues/7195 into context, then
> wait for further instructions.

I find that telling it to wait prevents the LLM from getting ahead of
itself and trying to implement a fix.

### Reproduce the bug locally

Now that the session has the context it needs, the next thing I do is
see if I can replicate the issue locally. This is where `/run-hub` comes
in handy. Without it, I would have had to spin up the app and stumble
through seeding it to replicate the issue.

> Using /run-hub, can you load the screen mentioned in the issue so I
> can better understand the problem?

![Hub skills page where iOS is listed under Highlighted abilities next to Rails, while the Tools table below shows iOS as Very Opposed](https://images.thoughtbot.com/y70sk802qsi3u60g1npwrk8bjxax_1.png)

### Don't be afraid to ask naive questions

Now that I could see the issue myself, I took more time to scrutinize
it. I could see that beneath the "Highlighted abilities" card was
another table that rendered the employee's skills alongside their
interest level.

> /eli5 the issue this ticket aims to solve. I'm a little confused
> because I see that we render iOS as "Very Opposed" on the page.

Here's the part of the response that made it click for me:

> The "Very Opposed" you saw is in the lower table. The bug is in the
> top box, which shows the same skill with no interest at all.
>
> Someone skimming the top box reads "iOS mentor, starred" and never
> scrolls down to "Very Opposed".

After a quick back-and-forth, it was clear that this was a UI issue.
Even though we were showing the employee's interest level, it was
overshadowed by the "Highlighted abilities" card.

### Trace what actually happens

Now that I had a better sense of the issue, I wanted to understand how
the employee's highlighted skills affect their eligibility for
opportunities. At this point, I wasn't sure if an employee was
automatically selected as a candidate for an opportunity based on their
interest level, or if someone from delivery manually selected them based
on their highlighted skills.

> Using /trace can you trace the lifecycle of an Opportunity to help
> figure out how he was selected for the project?

The answer surprised me. **The app never selected him.** A background
job matches people to an opportunity, and it already skips anyone who is
Opposed or Very Opposed to the skill. So, a person most likely picked
him after seeing iOS starred on his profile.

This was an important distinction, because it meant the fix belonged on
the profile, not in the matching logic.

![Claude Code trace summary next to the generated trace document, showing the matching job marks the Very Opposed person as not applicable while their profile still stars iOS](https://images.thoughtbot.com/wfmy85dc8hjkrzl7jh5w9zsvqdkn_2.png)

### Let the LLM quiz you

At this point, I had a firm understanding of the problem, but in an
effort to cement that understanding, I used the Socratic method to
ensure I could defend it.

> Using /understand, help ensure I understand the problem this ticket
> aims to solve. I'm not interested in the implementation details, just
> the behavior.

Instead of explaining the problem to me, it asked me to explain it back,
and then poked holes in my answer. Here's the exchange that changed my
mind:

> **Me:** He sees his "highlighted" skills in a card at the top of the
> page. The issue is that card does not indicate that he's opposed to
> skills he's really good at.
>
> **LLM:** … Say we add a red "Very Opposed" badge next to iOS in that
> card and change nothing else. Would [his] problem be solved?
>
> **Me:** No, probably not. Instead, we should just remove the skill
> from that card.
>
> **LLM:** Right. The badge still leaves iOS starred as one of his top
> skills, and the star is what got him pinged.

I originally figured we could just add the interest level to the card,
but that would have missed the point.

### Slice it into a SPEC

Now that I understood the problem, I felt comfortable moving forward
with creating a [vertical slice][slices]. If you're familiar with
[spec-driven development][sdd], this is a lightweight version of that.

> Let's create a SPEC for this using /slice

What I like about this is that it's focused on expected outcomes, not
implementation details. But it also provides the LLM (and a human)
enough context so it knows where to look. This is important because I do
the implementation in a separate session to avoid [context
pollution][context-rot].

Below is what it generated. I also made sure to add this to the ticket
to serve as a central source of truth, and to give other engineers an
opportunity to review it.

```markdown
# Hide opposed skills from Highlighted abilities

The Highlighted abilities card on a person's skills page leaves out featured
skills they're Opposed or Very Opposed to. It uses the same interest rule the
app already applies to featured skills in `Person#public_skills`, and the card
stays on the page even when that leaves it empty.

## Job story

When a teammate scans my skills page to find people for a new project
I want the skills I've said I'm opposed to kept out of my highlighted strengths
So I can keep my level on record as a resource without being pitched onto work I don't want

## Acceptance criteria

- [ ] Given a person is Mentor on a featured skill (iOS) and Very Opposed to it, when anyone views their skills page, then iOS isn't listed under Highlighted abilities
- [ ] Given a person is Opposed to a featured skill, when anyone views their skills page, then that skill isn't listed under Highlighted abilities
- [ ] Given a person is Neutral, Interested or Very Interested in a featured skill, when anyone views their skills page, then that skill is still listed under Highlighted abilities
- [ ] Given a person is Very Opposed to a featured skill, when anyone views their skills page, then the skill still shows in its skill-type table below with its level and "Very Opposed"

## Where to look

Paths as of `2cc8f3453`. Where the code was, not what to build.

- `app/presenters/person_abilities_presenter.rb` — `by_featured_skill` is the card's only data source and ignores interest
- `app/models/ability.rb` — `interested` / `uninterested` scopes already define the Opposed + Very Opposed rule
- `app/models/person.rb` — `public_skills` (line ~90) applies the same rule to featured skills for the API
- `app/views/people/skills/index.html.erb` — the card renders unconditionally, so an empty result shows the heading with no rows
- `spec/presenters/person_abilities_presenter_spec.rb` — existing `#by_featured_skill` spec to extend; `bundle exec rspec spec/presenters/person_abilities_presenter_spec.rb`

## What I cut

- Hiding the card when it's empty. It stays, empty, the way it looks today for anyone with no featured skills.
- Showing interest in the card, and fixing the legend (the second comment on the issue). Once opposed skills are gone, everything left in the card has positive or neutral interest.
- The staffing tab's "Show all people" still shows opposed people next to real candidates. It's a different screen, so it'd be a separate ticket.
```

My favorite part is the "What I cut" section. It makes it clear what
we're **not** doing, which keeps the implementation (and the PR) small.

## Ship it in a fresh session

Now that I have a sound understanding of the problem and a SPEC to guide
the LLM, I create a new session to start the implementation phase. This
is either the most or least interesting step of the process,
depending on how much AI-assisted development you do.

> /ship the SPEC outlined in the GitHub issue. During the verification
> phase, use the `/run-hub` skill. Take screenshots for all the cases
> mentioned in the acceptance criteria. Do this with a dynamic workflow.

The idea is that a [dynamic workflow][dynamic-workflow] will orchestrate
the following steps in **separate** sessions. This is important because
it ensures the session that wrote the code isn't also the one reviewing
it. A session reviewing its own code is biased toward it.

1. Identify any [preparatory refactors][prep-refactor].
2. Implement the solution with a shameless green, [outside-in
   TDD][outside-in] approach.
3. Review the implementation against multiple axes, including the SPEC.
4. Verify the implementation against the SPEC.
5. Explain the change, including the why, risks, and trade-offs.

After 54 minutes, the LLM landed on this simple one-line solution.

```diff
# app/presenters/person_abilities_presenter.rb

 abilities
   .joins(:skill)
   .merge(Skill.featured)
+  .merge(Ability.interested)
   .sort_by(&method(:skill_level_type_and_name))
```

That might seem like a lot of time, but you have to remember that the
LLM is implementing this with [TDD][robocalypse], then doing a thorough
independent review, and finally verifying each case of the acceptance
criteria while providing screenshots.

During this time, I'm not interacting with the session. Instead, I work
on something else in parallel.

## Verify and review yourself

Once I came back to the session, I manually verified the work.

> Can you spin up the dev server and tell me what page to view so I can
> review myself.

![Hub skills page after the fix, with only Rails under Highlighted abilities and iOS still listed as Very Opposed in the Tools table](https://images.thoughtbot.com/2uwz6urxymmjzqoa4g6a7lo4kimr_Hub%20-%20Skills-screenshot.png)

Additionally, I reviewed the artifact my
[`/diff-explainer`][diff-explainer] skill generated, so that I could get
a sense of the **why** behind the change. This allows me to understand
risks, trade-offs, and alternative approaches. This is similar to what
you would expect from a colleague's PR description, since you were not
around for each decision made during implementation.

## Write the PR description yourself

I'm OK with LLM-generated commit messages, since the LLM holds all the
context. I think of it as an audit log. However, I still think it's
important to [write the PR description yourself][team-mad]. It adds
credibility, and also ensures you can explain and defend the spirit of
the change. If I do use an LLM to write prose, like the SPEC above, I
add a note saying so. In that case, it was "AI-generated, but I vetted
it and am adding it for posterity."

My [`/pr`][pr-skill] skill reads the branch, suggests a title, and gives
me a brief of what changed, the risks, and the trade-offs. Then it
**refuses** to write the description for me. Since we [squash-merge our
PRs][squash], the description becomes the commit message on `main`, so
it should be in my words.

> **Changed**
>
> - A skill you're Opposed or Very Opposed to no longer shows in the
>   Highlighted abilities card, even when your level is high (Mentor on
>   iOS, say).
> - It still shows in its skill-type table lower down the page, with its
>   level and "Very Opposed".
>
> **Tradeoffs**
>
> - It reuses the `Ability.interested` scope but doesn't share
>   `Person#public_skills` itself.
>
> **Suggested title:** `Hide opposed skills from Highlighted abilities`
>
> Now write the description in your own words.

Here's what I wrote:

> The spirit of this commit is to remove a skill from the "Highlighted
> abilities" card if the person is "Opposed" or "Very Opposed". We
> _could_ have just updated the card to show the person's interest
> level, but that would defeat the purpose. Why imply an ability is
> highlighted if the person is opposed to it? Also, that information
> lives on the card below, so removing it from the "Highlighted" section
> doesn't remove it completely.

Notice that the reasoning came straight from my `/understand` session.

What's nice about this approach is that the LLM can help proof and
verify your message, and take care of cumbersome things like providing
screenshots, examples, or linking to GitHub issues.

## A few more heuristics

Finally, I want to share some heuristics I follow that have helped.

### Make the commit as small as possible

My [`/implement-with-tdd`][tdd-skill] skill caps a change at around 200
lines of code. Keeping the LLM constrained means it's easier for the LLM
(or a human) to review the work. Plus, the feedback loop is faster, and
it uses fewer tokens. It's the same reason we [work
iteratively][small-prs].

### Audit your harness

If the LLM did something you didn't like, correct it. You can improve or
create a skill, adjust your `CLAUDE.md`, or [add a linter][linter].

Additionally, consider limiting the number of skills you use. I find
that less is more, since they can sometimes conflict. If you're using
Claude Code, the [`/doctor`][doctor] skill can find unused skills and
what they cost in context.

## Wrapping up

The LLM wrote one line of code. Most of my time went into understanding
the problem, slicing it, and verifying the fix, and I think that's where
it belongs.

None of this is new. Before LLMs, we still planned before we started
coding, we still used TDD, and we still reviewed our colleagues' PRs
without the full context. What's changed is that an LLM can accelerate
each of those steps. What hasn't changed is that I'm still responsible
for what ships.

[skills]: https://github.com/stevepolitodesign/skills#how-to-use-these-skills
[slices]: https://thoughtbot.com/blog/break-apart-your-features-into-full-stack-slices
[small-prs]: https://thoughtbot.com/blog/working-iteratively
[run-verify]: https://code.claude.com/docs/en/skills#run-and-verify-your-app
[dynamic-workflow]: https://code.claude.com/docs/en/workflows
[sdd]: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
[context-rot]: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
[diff-explainer]: https://github.com/stevepolitodesign/skills#diff-explainer
[pr-skill]: https://github.com/stevepolitodesign/skills#pr
[tdd-skill]: https://github.com/stevepolitodesign/skills#implement-with-tdd
[doctor]: https://code.claude.com/docs/en/commands
[prep-refactor]: https://thoughtbot.com/blog/finding-the-time-to-refactor
[outside-in]: https://thoughtbot.com/blog/testing-from-the-outsidein
[robocalypse]: https://thoughtbot.com/blog/prevent-the-robocalypse-with-tdd
[team-mad]: https://thoughtbot.com/blog/how-to-use-llms-without-driving-your-team-mad
[squash]: https://thoughtbot.com/blog/don-t-forget-the-silent-step-when-you-squash-and-merge
[linter]: https://thoughtbot.com/blog/enforcing-your-ruby-style-guide-on-ai-generated-code
