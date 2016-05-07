# FulcrumAgent

An umbrella project for the `FulcrumAgent` things.

Plans include:

* [`docker_stream`](https://github.com/tolerable-tech/fulcrum_agent/tree/master/apps/docker_stream): listens to docker events and rebroadcasts them internally.
* [`nginx_registry`](https://github.com/tolerable-tech/fulcrum_agent/tree/master/apps/nginx_registry): not really sure what to call this, but it'll be something that listens to docker events and sets up etcd keys for NGINX to look at. So it'll need docker info and also to peek at PG records to lookup if there's a hostname specified.
* `component_registry`: look at moving stuff out of the Fulcrum phoenix app into here for things like looking up components and managing their storage in PG
* `component_manager`: might be combined with the registry bit under a better name that I haven't thought of yet, but something that manages starting/stopping/adding/removing components from fleet/docker.

So this will end up as a dependency of the Fulcrum Phoenix app, so what's the point?

Organization, and a clearer supervision tree within the app getting us a separationg of concerns.

So, from a supervision tree perspective, I'm super new to them and want them to be simple. In this umbrella app, each one is its own application with its own tree, which is nice.

Seperation of concerns same sort of deal.

My plan is for each thing to just register any shared processes as named things (which seems to be a best practice?) and then define a public interface that the apps can call.

In the end I might pull the Phoenix app into this as well once it's only a frontend piece just for dependencies sake, but I'm not sure if that's a good idea or not yet.

</hr>

> Copyright © 2016  Tolerable Technology
> 
> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
> 
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU General Public License for more details.
> 
> Please see LICENSE.txt for a full copy of the GNU General Public License.
>
