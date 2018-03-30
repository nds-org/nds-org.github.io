# nds-org.github.io
Static site for listing interesting blog posts from NDS

# Building on GitHub Pages
When a new commit is pushed to this repo, the static site at https://nds-org.github.io/ will be rebuilt and automatically updated to reflect the changes.

# Building Locally with Jekyll
NOTE: Docker is recommended

You will need to install Ruby + Jekyll to build locally on your host.

To simply output the static `_site/` that GitHub Pages would display:
```bash
jekyll build
```

This will build and output a `_site/` folder with HTML/CSS generated from your source files by Jekyll.

To serve the example page and debug it, you can use the following instead:
```bash
jekyll serve
```

You should then be able to navigate to http://localhost:4000 to preview how your site will look on GitHub Pages.

## Watch for File Changes
```bash
jekyll serve --watch
```

## Rapid Testing with LiveReload
To start up a web server that automatically rebuil;ds/refreshes your browser while editing, run the following command:
```bash
jekyll serve --livereload
```

With `--livereload` enabled, any new build will automatically trigger your browser to refresh the current page that if it is navigated to 127.0.0.1:4000.

# Building Locally With Docker
Pull a pre-built image:
```bash
docker pull ndslabs/jekyll
```

Or you can build the image yourself if you need to make changes to it:
```bash
docker build -t ndslabs/jekyll .
```

To simply output the static `_site/` that GitHub Pages would display:
```bash
docker run -d --name=jekyll --label=jekyll --volume=$(pwd):/srv/jekyll  -it -p 127.0.0.1:4000:4000 ndslabs/jekyll build
```

This will build and output a `_site/` folder with HTML/CSS generated from your source files by Jekyll.

To serve the example page and debug it, you can use the following instead:
```bash
docker run -d --name=jekyll --label=jekyll --volume=$(pwd):/srv/jekyll  -it -p 127.0.0.1:4000:4000 ndslabs/jekyll serve
```

You should then be able to navigate to http://localhost:4000 to preview how your site will look on GitHub Pages.

NOTE: There can be slight differences between GH Pages and the local environment that may interfere with your testing.

## Watch for File Changes
```bash
docker run -d --name=jekyll --label=jekyll --volume=$(pwd):/srv/jekyll  -it -p 127.0.0.1:4000:4000 ndslabs/jekyll serve --watch
```

## Rapid Testing with LiveReload
To start up a web server that automatically rebuil;ds/refreshes your browser while editing, run the following command:
```bash
docker rm -f jekyll; docker build -t ndslabs/jekyll . && docker run -d --name=jekyll --label=jekyll --volume=$(pwd):/srv/jekyll  -it -p 127.0.0.1:4000:4000 -p 127.0.0.1:35729:35729 ndslabs/jekyll serve --watch --livereload && docker logs -f jekyll
```

With `--livereload` enabled, any new build will automatically trigger your browser to refresh the current page that if it is navigated to 127.0.0.1:4000. 

## One-Line Rebuild
To quickly rebuild and restart your container in one line, you can run the following:
```bash
docker rm -f jekyll; docker build -t ndslabs/jekyll . && docker run -d --name=jekyll --label=jekyll --volume=$(pwd):/srv/jekyll  -it -p 127.0.0.1:4000:4000 -p 127.0.0.1:35729:35729 ndslabs/jekyll serve --watch --livereload && docker logs -f jekyll
```

This will perform the following actions:
* Remove any existing Docker container named `jekyll` (this will be a no-op if no such container exists)
* Build a new `ndslabs/jekyll` Docker image from source (caching is enabled, so this should be fast if nothing has changed)
* Run a new container from the `ndslabs/jekyll` image we just built in the background in `--watch` and `--livereload`  modes (NOTE: `--livereload` requires additionally exposing port `35729`)
* View the logs of the newly-created container

NOTE: with `--watch` and `--livereload` enabled, you should only need to rebuild if you change your `_config.yml` file changes
