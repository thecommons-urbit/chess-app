# `%chess`

## About

`%chess` is an [Urbit](https://urbit.org) app which allows you to play chess with other Urbit users. It is a
fully-decentralized, peer-to-peer chess application.

The original `%chess` was made by Raymond E. Pasco for several reasons:
- To practice Hoon
- As a hobby project
- As a proof-of-concept that users could share software between ships using Urbit "desks"

You can find his original repository for Urbit Chess [here](https://git.sr.ht/~ray/urbit-chess) and his Urbit Chess
Announcements page [here](https://lists.sr.ht/~ray). Ray paused work on `%chess` in March 2021 due to personal reasons.

In August 2021, Tlon (who at the time performed the Urbit project management duties presently performed by the Urbit
Foundation) released software distribution in an update to Arvo. `~finmep-lanteb` updated `%chess` to work with this
update as an example of app distribution for Assembly 2021. Afterwards, he continued to support the app to add features
and improve usability.

In September, 2022, `~bonbud-macryg`, `~nordus-mocwyl`, and `~rovmug-ticfyn` began working on `%chess` in their spare
time for an [Urbit Foundation bounty](https://urbit.org/grants/chess-bounty), which they completed in September, 2023.
Since then, they have continued to help maintain the app.

## Install

This repo contains only the Hoon code for the chess agent, without any sort of user interface. See the
[chess distribution repo](https://github.com/thecommons-urbit/chess) for detailed instructions on how to install the
chess app.

**NOTE:** The above advice is not only for users, but also developers. Developing / testing with an interface is *much*
easier.

## Development

Below is a step-by-step guide for working on `%chess` and testing changes. This section assumes at least minor Urbit
development experience, i.e.:
- familiarity with Unix-based systems
- familiarity with Git
- completion of at least [Hoon School](https://docs.urbit.org/courses/hoon-school) and preferably also
  [App School](https://docs.urbit.org/courses/app-school)

The above is not to say that people with no prior development experience are barred from contributing, just that this is
not a place to receive guided help. There are plenty of issues with `%chess` that need fixing, many of which are simple
and would be good "first-time" Urbit contributions.

### 0. Setup your development environment

See [this guide](https://docs.urbit.org/courses/environment) on the Urbit developers portal for information on
how to get the Urbit binaries and what sort of software may be useful for developing Urbit applications.

### 1. Pull a copy of the `%chess` code

```
git clone https://github.com/thecommons-urbit/chess-app.git
```

### 2. Do development stuff

Check out the [IDEA Hoon plugin](https://github.com/ashelkovnykov/idea-hoon-plugin) if you want to work on Hoon in a
fully-fledged IDE, instead of vim/emacs/VSC!

### 3. Setup test ship

Create a development ship:
```
./urbit -F zod
```

Create a `%chess` desk from inside your dev ship:
```
|new-desk %chess
```

Mount the `%chess` desk, so that code can be pushed to it:
```
|mount %chess
```

### 4. Install the `%chess` app

Push the `%chess` code onto the dev ship:
```
cp -rfL [path to chess code]/src/dependencies/* [path to development ship]/chess/
cp -rfL [path to chess code]/src/chess/* [path to development ship]/chess/
```

Alternatively, you can run the provided installation script to copy the `%chess` code. Substitute the path to the pier
parent folder using option `-p`, and the ship's name using option `-s`:
```
./bin/install.sh -p /home/user/Urbit -s zod
```

Commit the changes from inside your dev ship:
```
|commit %chess
```

The first time you commit `%chess` code to a fake ship, you will need to install the app:
```
|install our %chess
```

### 5. Testing with other ships

You can launch multiple test ships to communicate with each other to test `%chess`. Any other test ships on your
computer are able to install `%chess` just like they would if they were real ships:
```
|install ~zod %chess
```

#### NOTE: About fake-ships

Fake-ships hosted on the same computer can talk to each other, but they still have 'realistic' packet routing. This
means that fake galaxies can talk to each other, but fake planets cannot, unless they have appropriate fake stars and
fake galaxies also active on the computer to route for them. Examples:

```
~tex & ~mex:            GOOD
~tex & ~bintex:         GOOD
~mex & ~bintex:         BAD
~tex, ~mex, & ~bintex:  GOOD
```

## Contributors

Appearing in alphabetical order of `@p`:

- `~bonbud-macryg` - [@bonbud-macryg](https://github.com/bonbud-macryg)
- `~datder-sonnet` - Tom Holford, [@tomholford](https://github.com/tomholford)
- `~finmep-lanteb` - Alex Shelkovnykov, [@ashelkovnykov](https://github.com/ashelkovnykov), `~walbex`
- `~nordus-mocwyl` - [@brbenji](https://github.com/brbenji)
- `~rovmug-ticfyn` - [@rovmug-ticfyn](https://github.com/rovmug-ticfyn)
- `~sigryn-habrex` - [Raymond E. Pasco](https://ameretat.dev)
