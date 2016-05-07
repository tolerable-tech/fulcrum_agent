# DockerStream

Rebroadcast events received from Docker into Elixir.

Public API is available at `DockerStream.API` where you can `register/2` and
`deregister/2` your `GenEvent` handlers to receive events.

## Next Steps?

* an agent process that memoizes the pertinent bits of the response from
  `inspect_container` so that we can send those in `die` & `destroy` events

* have `DockerStream.Broadcaster` use another agent that would allow a `GenEvent`
  manager per event type, so that clients could subscribe to only the events they're
  interested in.


