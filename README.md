Node-webkit-bootstrap
=====================

This Ruby gem provides a framework for bootstraping, running, building
and testing your [node-webkit](https://github.com/rogerwang/node-webkit) applications.

How to use?
-----------

`node-webkit-bootstrap` provides a set of `rake` tasks that automatize the following:
* Downloading `node-webkit`
* Preparing a runtime directory
* Bundling a stand-alone version of your app
* Running tests using `node-webkit`

### Basic Layout

Here is a typical layout:
```
(root)
|-- Gemfile
|-- Rakefile
|-- app/{index.html, js/, ...}
       |-- vemdor/arch/win/ia32/win.js
       |-- vendor/arch/osx/ia32/osx.js
|-- vendor/node-webkit-bootstrap/node-webkit/win/ia32/foo.dll
|-- vendor/node-webkit-bootstrap/node-webkit/osx/ia32/Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/libfoo.so
|-- test/{index.html, js, ...}
```

With:
```
% cat Gemfile
(...)
gem "node-webkit-bootstrap", "~> 1.0.0"
```

```
% cat Rakefile
(...)
require "node-webkit-bootstrap/rake"

NodeWebkitBootstrap::Rake.register do |config|
  config.app = "my-awesome-app"
  
  here = File.expand_path "..", __FILE__
  config.app_path  = "#{here}/app"
  config.test_path = "#{here}/test" 

  config.run_package = {
    name: config.app,
    main: "index.html",
    window: {
      toolbar: true,
      width:   660,
      height:  500
    }
  }

  config.build_package = {
    name: config.app,
    main: "index.html",
    window: {
      toolbar: false,
      width:   660,
      height:  500
    }
  }

  config.test_package = {
    name: config.app,
    main: "index.html",
    window: {
      show: false
    }
  }
end
```

This configures the following rake tasks:
```
% rake -T
(...)
rake my-awesome-app:build[platform]    # Build my-awesome-task (platform is one of: "win", "linux", "osx" or "all", default: "all").
rake my-awesome-app:download[version]  # Download latest node-webkit code (default version: 0.4.2).
rake my-awesome-app:run                # Run my-awesome-task.
rake my-awesome-app:test               # Run my-awesome-task tests.
```

### Downloading node-webkit

The `download` task fetches `node-webkit` binaries and create various `tmp/node-webkit/#{platform}/#{arch}`. 
Available platforms and architectures are:
```
# format: platform => [architectures]
{ linux:  [:ia32, :x64],
   osx:    [:ia32],
   win:    [:ia32] }
```

Running the download task yields:
```
% rake my-awesome-app:download
(...)
Downloading node-wekbit binary for osx ia32
Downloading https://s3.amazonaws.com/node-webkit/v0.4.2/node-webkit-v0.4.2-osx-ia32.zip to tmp/node-webkit-v0.4.2-osx-ia32.zip
Decompressing tmp/node-webkit-v0.4.2-osx-ia32.zip
(...)
Extracting Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/node-webkit Helper
Extracting Contents/Frameworks/node-webkit Helper.app/Contents/PkgInfo
Extracting Contents/Info.plist
Extracting Contents/MacOS
Extracting Contents/MacOS/node-webkit
Extracting Contents/PkgInfo
Extracting Contents/Resources
Extracting Contents/Resources/nw.icns
Vendoring Contents/Frameworks/node-webkit Framework.framework/Libraries/ffmpegsumo.so
Vendoring Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/libfoo.so
Done!

Downloading node-wekbit binary for win ia32
(...)
```

All the files from `node-webkit`'s archive are thus extracted and the `libfoo.so` file is picked
from the `vendor/node-webkit-bootstrap/node-webkit/osx/ia32` folder.

All files placed in to a `vendor/node-webkit-bootstrap/node-webkit/#{platform}/#{arch}` folder
will likewise be added to the corresponding `node-webkit`'s directory. You can use this directory
to add all files you want to override from `node-webkit` upstream's files, such
as for instance the OSX application package description files.

Please note that, by default. `node-webkit-bootstrap` will vendor GPL versions of the `ffmpeg`
library to gain proper multimedia playback.

### Running your app

Executing the `run` task runs your application files using the `node-webkit` binary 
appropriate for your architecture:
```
% rake my-awesome-app:run
(...)
tmp/node-webkit/osx/ia32/Contents/MacOS/node-webkit tmp/node-webkit-bootstrap/my-awesome-app-run
[35457:0315/152311:ERROR:renderer_main.cc(179)] Running without renderer sandbox
(...)
```
The path to your app is given by `config.app_path` in your `Rakefile` above. Also, a 
`package.json` file is generated using data from `config.run_package` in your `Rakefile`.

### Building your app

Executing the `build` task generates bundled versions of your application:
```
% rake my-awesome-app:build
touch tmp/node-webkit-bootstrap/my-awesome-app-run
Creating build/my-awesome-app-osx-ia32.nw
Adding index.html
Adding package.json
Adding vendor
Adding vendor/arch/osx/ia32
Adding vendor/arch/osx/ia32/osx.js
Adding vendor/js
Adding vendor/js/jquery.js
Creating build/my-awesome-app-osx-ia32.zip
Adding my-awesome-app.app/Contents
Adding my-awesome-app.app/Contents/Frameworks
Adding my-awesome-app.app/Contents/Frameworks/node-webkit Framework.framework
Adding my-awesome-app.app/Contents/Frameworks/node-webkit Framework.framework/Libraries
Adding my-awesome-app.app/Contents/Frameworks/node-webkit Framework.framework/Libraries/ffmpegsumo.so
(...)
Adding my-awesome-app.app/Contents/Resources/app.nw
Adding my-awesome-app.app/Contents/Resources/nw.icns
(...)
```

As you can see, the task will first create a `build/my-awesome-app-osx-ia32.nw` archive.
Here again, a `package.json` file is generated using data from `config.build_package`
in your `Rakefile`.

In the case where you app has a `vendor/arch` directory, the `nw` archive for a given 
`platform` and `arch` only contains files under `vendor/arch/#{platform}/#{arch}`.
You can use this option to vendor architecture-specific files inside the `nw` archive.

Finally, the `nw` archive is bundled together, according to each platform's technique
and a `build/my-awesome-app-#{platform}-#{arch}.zip` file is created that you should
be able to distribute.

### Testing

Executing the `test` task works exactly as with the `run` task except that the files specified
by `config.test_path` in your `Rakefile` are used instead of `config.app_path`. Likewise, a `package.json`
file is created using data from `config.test_package` in your `Rakefile`. 

You can use this task to run your tests in a specific `node-webkit` testing app.

### Server-side tests

In the case where most of your application's code is delivered by a server, you can
also use `node-webkit-bootstrap` for testing it. 

This is particularly useful because in this case your app's code is likely to have node-specific code
such as `require("os")` which cannot be properly tested without `node-webkit`.

Similarly to the case of your app, you have to include `node-webkit-bootstrap` in your `Gemfile`.
Then you add the following to your `Rakefile`:
```
% cat Rakefile
(...)
require "node-webkit-bootstrap/rake"

NodeWebkitBootstrap::Rake.register ["test"] do |config|
  config.app = "nw"
  
  here = File.expand_path "..", __FILE__
  config.test_path = "#{here}/test" 
  
  config.test_package = {
    name: config.app,
    main: "index.html",
    window: {
      show: false
    }
  }
end
```

In this case, `node-webkit-bootstrap` will only add a `test` task:
```
% rake -T
(...)
rake nw:test   # Run nw tests.
```

You can use this task to run your tests on the server side.
