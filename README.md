#### Test

Let me describe test task.

This will be a bit open task so we can test your skills on design, problem thinking and solidity skills.
Let's say we have a map with coordinates.

The map starts created by the first owner (contract creator) with the following coordinate dimensions [x1,x2]x[y1,y2] (a rectangle).

Now we have 2 possible actions.

- ## FIRST ACTION:

  getting terrain on that map.
  next person comes and wants to own a plot with certain coordinates [xx1,xx2]x[yy1,yy2] contained inside the limits of the map (this is not a purchase/buy, just the creator allowing others to use the plot and build)

  That creates a proposal which is voted on by the current owner (initially this is the creator only)
  This needs to check that the terrain on the proposal is available.
  If it is approved, then that new guy is added as an owner - that terrain becomes unavailable after
  Proposals are added and resolved in chronological order

- ## SECOND ACTION:

  extending the map
  This is a proposal to extend the dimensions of the terrain (which was initally limited, for example 30x30 plots)
  Need to be coordinates [xxx1,xxx2]x[yyy1,yyy2] not contained on the map currently
  This is also voted on by all owners of the current plos

  You need to propose an scalable way of:

  - Storing the maps (coordinates)
  - Comparing if some terrain is not available
  - Voting system
