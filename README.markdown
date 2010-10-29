# Achievements

Achievements is a drop in Achievements/Badging engine designed to work
with Ruby, ORM backed web applications.

Achievements uses Redis for persistence and tries to be as abstract as
possible, essentially acting as a counter server with assignable
thresholds.

The application Achievements was developed for uses a User class to
instantiate the Engine and an Achievement class to persist the details
of the achievements on the application side.

## Contexts

Contexts are categories for achievements.  Every time an achievement
is triggered, it's "parent" or context counter is also triggered and
incremented.  This makes it easier to gauge overall participation in
the system and makes "score" based calculations less expensive.

## Achievements

Achievements are named, contextualized counters with one or more thresholds. 

## Output

When a threshold isn't crossed, and nothing changes, the engine will
return nothing when triggered.

When a threshold is crossed, the engine will return an array of
symbols which correspond to the names of the achievements which have
been reached.  Your application can consume this output as you see
fit.

## Achievement API Compliance

Your Achievement class must have a name, context, and threshold method
in order to adapt to the Engine.

### TODO

