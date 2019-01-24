# aksworkshop.io

This is the repository for the AKS Workshop website.

## Technology

- The website is statically built using Jekyll and you’ll find the different pages inside the `_entries` folder.
- If you’re on a Mac/Linux machine, you can preview your edits locally if you run `make build-run` inside the repo root.

## Branching and contribution

- The branch [`aksworkshop-master`](https://dev.azure.com/theazurechallenge/Kubernetes/_git/Challenges?version=GBaksworkshop-master) gets published to [aksworkshop.io](http://aksworkshop.io).
- The branch [`aksworkshop-staging`](https://dev.azure.com/theazurechallenge/Kubernetes/_git/Challenges?version=GBaksworkshop-staging) gets published to [staging.aksworkshop.io](http://staging.aksworkshop.io).
- Publishing to [aksworkshop.io](http://aksworkshop.io) happens through merges only, through merging into `aksworkshop-master` from the `aksworkshop-staging` branch.
- Please branch off `aksworkshop-staging` if you want to contribute, then submit a Pull Request to `aksworkshop-staging`.
- If you want your name to show up in the [contributors](http://aksworkshop.io/#contributors), please add your GitHub username to `_entries/04 Contributors.md` in alphabetical order.