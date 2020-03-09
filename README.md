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
    - uses: David-Byrne/jekyll-diff-action@v1.2.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

If you don't want the action to run on both commits and PRs, remove whichever trigger you don't need. The `GITHUB_TOKEN` is required to allow the action comment the diff back on GitHub.

And that's pretty much it! From now on, any changes you make on GitHub should have a comment showing their impact on the final version of your site, like this:

``` diff
--- /tmp/old/hello.html
+++ /tmp/new/hello.html
@@ -1 +1 @@
-<h1>hello world</h1>
+<h1>Hello World!</h1>
```

While simple markdown updates usually result in trivial HTML changes, (e.g. the diff above), bumping dependencies or adding new plugins can cause many hard to detect issues. This is where jekyll-diff-action really shines, nothing on your site changes without your knowledge.


## Licence
Jekyll diff action is released under an [MIT licence](/LICENSE).
