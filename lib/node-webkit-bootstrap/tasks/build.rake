require "json"
require "zip/zip"

NodeWebkitBootstrap::Rake.add_tasks do
  app  = NodeWebkitBootstrap::Rake.app
  path = NodeWebkitBootstrap::Rake.app_path

  desc "Build #{app} (platform is one of: \"win\", \"linux\", \"osx\" or \"all\", default: \"all\")."
  task :build, [:platform] => ["tmp/node-webkit-bootstrap/#{app}-build", "tmp/node-webkit"] do |t, args|
    platform = args[:platform] || "all"

    if platform == "osx" or platform == "all"
      build_osx app
    end
    if platform == "win" or platform == "all"
      build_win app
    end
    if platform == "linux" or platform == "all"
      build_linux app, :ia32
      build_linux app, :x64
    end
  end

  file "tmp/node-webkit-bootstrap/#{app}-build" => FileList["Rakefile", "#{path}/**/*"] do
    NodeWebkitBootstrap::Rake.build_runtime app, path, :build 
  end

  def build_osx app
    build_nw app, :osx, :ia32
    basedir = "tmp/node-webkit-bootstrap/#{app}-osx-ia32"

    FileUtils.rm_rf basedir
    FileUtils.cp_r  "tmp/node-webkit/osx/ia32", basedir
    FileUtils.cp    "build/#{app}-osx-ia32.nw",    "#{basedir}/Contents/Resources/app.nw"

    archive = "build/#{app}-osx-ia32.zip"
    puts "Creating #{archive}"

    FileUtils.rm_f archive
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      Dir["#{basedir}/**/*"].each do |file|
        file.gsub! "#{basedir}/", ""
        target = "#{app}.app/#{file}"

        puts "Adding #{target}"
        zip.add target, "#{basedir}/#{file}"
      end
    end
  end

  def build_win app
    build_nw app, :win, :ia32
    basedir = "tmp/node-webkit-bootstrap/#{app}-win-ia32"

    FileUtils.rm_rf   basedir
    FileUtils.cp_r    "tmp/node-webkit/win/ia32", basedir
    sh "cat '#{basedir}/nw.exe' 'build/#{app}-win-ia32.nw' > '#{basedir}/#{app}.exe'"
    FileUtils.rm      "#{basedir}/nw.exe"

    archive = "build/#{app}-win-ia32.zip"
    puts "Creating #{archive}"

    FileUtils.rm_f archive
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      Dir["#{basedir}/**/*"].each do |file|
        file.gsub! "#{basedir}/", ""
        target = "#{app}/#{file}"

        puts "Adding #{target}"
        zip.add target, "#{basedir}/#{file}"
      end
    end
  end
 
  def build_nw app, platform, arch
    archive = "build/#{app}-#{platform}-#{arch}.nw"

    FileUtils.mkdir_p "build"
    FileUtils.rm_rf   archive

    puts "Creating #{archive}"
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      FileList["tmp/node-webkit-bootstrap/#{app}-build/**/*"].each do |file|
        target = file.sub("tmp/node-webkit-bootstrap/#{app}-build/","")

        # Filter app platform-specific vendor stuff.
        next if target.match "vendor/arch" and not target.match "vendor/arch/#{platform}/#{arch}"

        puts "Adding #{target}"
        zip.add target, file
      end
    end
  end

  def build_linux app, arch
    build_nw app, :linux, arch
    basedir = "tmp/node-webkit-bootstrap/#{app}-linux-#{arch}"

    FileUtils.rm_rf   basedir
    FileUtils.cp_r    "tmp/node-webkit/linux/#{arch}", basedir
    sh "cat '#{basedir}/nw' 'build/#{app}-linux-#{arch}.nw' > '#{basedir}/#{app}'"
    FileUtils.chmod   0755, "#{basedir}/#{app}"
    FileUtils.rm      "#{basedir}/nw"

    archive = "build/#{app}-linux-#{arch}.zip"
    puts "Creating #{archive}"

    FileUtils.rm_f archive
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      Dir["#{basedir}/**/*"].each do |file|
        file.gsub! "#{basedir}/", ""
        target = "#{app}/#{file}"

        puts "Adding #{target}"
        zip.add target, "#{basedir}/#{file}"
      end
    end
  end
end
