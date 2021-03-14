# Jekyll Diff Action

A Github Action that diffs the built Jekyll site after a change, and comments the result back to GitHub.

## Getting Started

Create a workflow file (e.g. `jekyll-diff.yml`) in `your-repo/.github/workflows/` directory, similar to:

``` yaml
name: Jekyll diff
on: [push, pull_request]

jobs:
  diff-site:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1

    - uses: David-Byrne/jekyll-diff-action@v1.3.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    - uses: actions/upload-artifact@v2
      with:
        name: jekyll-site.diff
        path: jekyll-site.diff
```

The `GITHUB_TOKEN` is required for the action to comment the diff back on GitHub. If you don't want the action to run on both commits and PRs, remove whichever trigger you don't need. If you need to support PRs from forks, use `pull_request_target` as the trigger, but remove the `GITHUB_TOKEN` since secrets should not be injected into an untrusted build. The diff will still be available in the `jekyll-site.diff` artefact of the build.

And that's pretty much it! From now on, any changes you make on GitHub should have a comment showing their impact on the final version of your site, like this:

``` diff
--- /jekyll-diff-action/old/hello.html
+++ /jekyll-diff-action/new/hello.html
@@ -1 +1 @@
-<h1>hello world</h1>
+<h1>Hello World!</h1>
```

While simple markdown updates usually result in trivial HTML changes, (e.g. the diff above), bumping dependencies or adding new plugins can cause many hard to detect issues. This is where jekyll-diff-action really shines, nothing on your site changes without your knowledge.


## Licence
Jekyll diff action is released under an [MIT licence](/LICENSE).
