---
title: "Automate manual deployments with Git and binstubs"
excerpt: "
  Your team’s manual deployment process doesn’t have to be so manual. Here’s how
  we automated our team’s deployment process with a few lines of bash and basic
  Git knowledge.
  "
categories: ["Web Development"]
tags: ["git"]
canonical_url: https://thoughtbot.com/blog/automate-manual-deployments-with-git-and-binstubs
---

I'm currently on a project that cannot use an automated continuous deployment
strategy because of our QA process and because our hosting environment does not
have an automated release feature. Our deployment process looks something like
this:

1. Merge a pull request into `main`.
2. The `main` branch is deployed to our staging environment.
3. Run QA against staging.

Once QA is complete, we then have to manually push `main` to production. This
usually includes several dozen commits, so I tend to compare the latest commit
on production with what I am about to push.

```sh
$ git fetch origin
$ git fetch production
$ git log origin/main...procution/main --oneline
```

I'll double-check with the team that those commits are the ones we want to push,
and then once confirmed, I'll go ahead and push to production.

```sh
$ git push production main
```

Not only is this inefficient, but it also prevents new team members from feeling
empowered to deploy the application. This results in only the most tenured team
members being able to deploy, which only exasperates the problem.

Surely there's got to be a better way, right?

## Use binstubs to automate repetitive tasks

Our project is already making use of [GitHub Actions] which runs linters, runs
tests and deploys to our staging environment if those two actions pass, so why
not just replicate this locally with a similar script? Well, that's exactly what
we did.

[GitHub Actions]: https://docs.github.com/en/actions

### Running CI locally

I figured the first thing we could do to improve our deployment process would be
to create a binstub to run CI for us. Not only could this be used as part of a
larger deployment script, but it can also be run in isolation too.

```sh
#!/bin/sh

set -e

echo "[bin/ci] Running CI..."
if ! bundle exec standardrb
then
  echo "[bin/ci] Linting failed. Exiting."
  exit 1
fi
if ! bin/rspec --fail-fast --tag ~type:system
then
  echo "[bin/ci] Tests failed. Exiting."
  exit 1
fi
if ! bin/rspec --fail-fast --tag type:system
then
  echo "[bin/ci] System tests failed. Exiting."
  exit 1
fi
echo "[bin/ci] CI Passed."
```

The goal here is to be as efficient as possible by running the fastest code
first, and making sure to exit immediately upon the first failure. There's no
sense in running the slow system test suite if a unit test failed, or if there's
a linting error. If one thing fails, the whole system fails.

### Configuring our production remote

In order to deploy to production, we'll need to make sure we have the remote
configured correctly. Rather than make a team member read the Wiki and set up
the remote manually, we can automate this process by running a few Git commands.

```sh
production=git@production.com/app.git

if [ "$(git config remote.production.url)" != "$production" ]
then
  echo "[bin/deploy] Configuring production remote..."
  git remote | grep production > /dev/null && git remote remove production
  git remote add production $production
fi
```

<aside class="info">
  💡 The call to <code>> /dev/null</code> is a technique to silence output. This means that
  we won't print the results from calling grep.
</aside>

The script checks if production is already configured. If it's not, we go ahead
and have it configure for the person calling the script.

### Showing what commits will be deployed

Since we're normally deploying more than one commit, I like to see what those
commits are just in case. This also gives me one last opportunity to confirm
with my team what will be deployed.

```sh
base_branch=main
current_branch="$(git branch --show-current)"
git fetch origin
git fetch production
diff="$(git log origin/main...production/master)"

if [ "$current_branch" != "$base_branch" ]
then
  echo "[bin/deploy] Please checkout main first."
  exit 1
fi

if [ -n "$diff" ]
then
  echo "[bin/deploy] The following commits will be deployed:"
  echo
  echo "$diff"
  echo
  echo "[bin/deploy] Would you like to deploy these commits? [y/N]"
  read -r response
  response="${response:-n}"
 if [ "$response" = y ]
 then
   bin/ci
   git push production main
 else
   echo "[bin/deploy] Exiting."
   exit 0
 fi
else
  echo "[bin/deploy] There are no new commits to deploy."
  exit 1
fi
```

<aside class="info">
  💡 We want to make sure we're on the <code>main</code> branch since we run the CI script
before deploying. If we didn't do this, CI would be running against the
currently checked out branch, and not <code>main</code>.
</aside>

You'll note that the team member executing this script needs to explicitly
opt in to the deploy by hitting "y". Typing any other key will exit the script
immediately.

You'll also note that we run `bin/ci` before we actually deploy. This ensures
that the code in `main` is in a deployable state.

### Putting it all together

Below is the final binstub for deploying to production. It takes several
cumbersome, repetitive tasks and condenses them down into one command that
anyone on the team (even folks who aren't developers) can run with confidence.

```sh
#!/bin/sh

set -e

base_branch=main
current_branch="$(git branch --show-current)"
production=git@production.com/app.git

if [ "$current_branch" != "$base_branch" ]
then
  echo "[bin/deploy] Please checkout main first."
  exit 1
fi

if [ "$(git config remote.production.url)" != "$production" ]
then
  echo "[bin/deploy] Configuring production remote..."
  git remote | grep production > /dev/null && git remote remove production
  git remote add production $production
fi
git fetch origin
git fetch production
diff="$(git log origin/main...production/master)"

if [ -n "$diff" ]
then
  echo "[bin/deploy] The following commits will be deployed:"
  echo
  echo "$diff"
  echo
  echo "[bin/deploy] Would you like to deploy these commits? [y/N]"
  read -r response
  response="${response:-n}"
 if [ "$response" = y ]
 then
   bin/ci
   git push production main
 else
   echo "[bin/deploy] Exiting."
   exit 0
 fi
else
  echo "[bin/deploy] There are no new commits to deploy."
  exit 1
fi
```

What's great about this is that if our deployment process changes, we can
capture that change in this script instead of a Wiki page which tends to be
outdated and less effective.
