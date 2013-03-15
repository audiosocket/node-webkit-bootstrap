require "curb"
require "rake"
require "rbconfig"
require "rubygems/package"
require "zlib"
require "zip/zip"

# Entry point for Rakefile

DSL = Rake::DSL

module NodeWebkitBootstrap
  class Rake
    class << self
      include DSL

      attr_accessor :app
      attr_accessor :app_path
      attr_accessor :run_package
      attr_accessor :build_package
      attr_accessor :test_package
      attr_accessor :test_path
    end

    @here = File.expand_path "..", __FILE__

    @app = "node-webkit-bootstrap"

    @run_package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: true,
        width:   660,
        height:  500
      }
    }

    @build_package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: false,
        width:   660,
        height:  500
      }
    }

    @test_package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: false,
        show:    false,
        width:   660,
        height:  500
      }
    }

    @app_path  = "#{@here}/bootstrap"
    @test_path = "#{@here}/test"

    def self.register tasks = ["*"], &block
      yield self if block_given?

      tasks.each do |task|
        FileList["#{@here}/tasks/#{task}.rake"].each do |f|
          import f 
        end
      end
    end

    def self.nw_version
      "0.4.2"
    end

    def self.nw_targets
      { linux:  [:ia32, :x64],
        osx: [:ia32],
        win:    [:ia32] }
    end

    def self.vendor_dirs platform, arch
      here = File.expand_path "..", __FILE__

      [ "#{here}/../vendor/node-webkit/#{platform}/#{arch}",
        # This one is for the app itself.
        "vendor/node-webkit-bootstrap/node-webkit/#{platform}/#{arch}" ]
    end

    def self.vendor_deps
      nw_targets.map do |platform, archs|
        archs.map do |arch|
          vendor_dirs(platform,arch).map do |dir|
            Dir["#{dir}/**/*"]
          end.flatten
        end.flatten
      end.flatten
    end

    def self.download_nw version = nw_version
      nw_targets.each do |platform, archs|
        case platform
          when :linux
            file_extension = "tar.gz"
            executables    = ["nw"]
          when :win
            file_extension = "zip"
            executables    = ["nw.exe"]
          when :osx
            file_extension = :zip
            executables    = [
              "Contents/MacOS/node-webkit",
              "Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/node-webkit Helper"
            ]
        end

        archs.each do |arch|
          puts "Downloading node-wekbit binary for #{platform} #{arch}"
          directory = "tmp/node-webkit/#{platform}/#{arch}"
          FileUtils.rm_rf   directory
          FileUtils.mkdir_p directory

          archive = "tmp/node-webkit-v#{version}-#{platform}-#{arch}.#{file_extension}"

          unless File.exists? archive
            failed = false
            url = download_url(version, platform, arch, file_extension)
            puts "Downloading #{url} to #{archive}"
            Curl::Easy.download url, archive do |curl|
              curl.on_failure do
                failed = true
              end
            end
            raise "Download failed for #{platform} #{arch}" if failed
          end

          puts "Decompressing #{archive}"
          if file_extension == "tar.gz"
            Gem::Package::TarReader.new(Zlib::GzipReader.open archive).each do |entry|
              next unless entry.file?

              path = entry.full_name.split("/")[1..-1].join "/"
              file = "#{directory}/#{path}"
              FileUtils.mkdir_p File.dirname(file)

              puts "Extracting #{path}"
              File.open file, "wb" do |fd|
                fd.write entry.read
              end
            end
          else
            Zip::ZipFile.open archive do |zipfile|
              zipfile.each do |file|
                path   = file.name.split("/")[1..-1].join "/"
                target = "#{directory}/#{path}"
                FileUtils.mkdir_p File.dirname(target)

                puts "Extracting #{path}"
                zipfile.extract file, target unless File.exists? target
              end
            end
          end

          vendor_dirs(platform,arch).each do |vendordir|
            if File.exists? vendordir
              Dir["#{vendordir}/**/*"].each do |file|
                next if File.directory? file

                path   = file.sub "#{vendordir}/",""
                target = "#{directory}/#{path}"
                FileUtils.mkdir_p File.dirname(target)

                puts "Vendoring #{path}"
                FileUtils.cp file, target
              end
            end
          end

          executables.each do |executable|
            FileUtils.chmod 0755, "#{directory}/#{executable}"
          end

          puts "Done!"
          puts ""
        end
      end
    end

    def self.download_url version, platform, arch, file_extension
      "https://s3.amazonaws.com/node-webkit/v#{version}/node-webkit-v#{version}-#{platform}-#{arch}.#{file_extension}"
    end

    def self.build_runtime app, path, mode
      basedir = "tmp/node-webkit-bootstrap/#{app}-#{mode}"

      FileUtils.rm_rf   basedir
      FileUtils.mkdir_p File.dirname(basedir)
      FileUtils.cp_r    path, basedir

      case mode
        when :build
          package = NodeWebkitBootstrap::Rake.build_package
        when :run
          package = NodeWebkitBootstrap::Rake.run_package
        when :test
          package = NodeWebkitBootstrap::Rake.test_package
       end

      File.open "#{basedir}/package.json", "w" do |file|
        file.write JSON.pretty_generate(package)
      end
      if package[:dependencies]
        sh "which npm && cd tmp/node-webkit-bootstrap/#{app}-build && npm install --production"
      end

      sh "touch tmp/node-webkit-bootstrap/#{app}-run"
    end

    file "tmp/node-webkit" => vendor_deps do
      download_nw
      sh "touch tmp/node-webkit"
    end

    def self.run_app app, mode
      case RbConfig::CONFIG["target_os"]
        when /darwin/i
          path = "tmp/node-webkit/osx/ia32/Contents/MacOS/node-webkit"
        when /mswin|mingw/i
          path = "tmp/node-webkit/win/ia32/nw.exe"
        when /linux/i
          case RbConfig::CONFIG["target_cpu"]
            when "x86_64"
              path = "tmp/node-webkit/linux/x64/nw"
            when "x86"
              path = "tmp/node-webkit/linux/ia32/nw"
          end
      end

      raise "Unsupported platform!" unless path

      sh "#{path} tmp/node-webkit-bootstrap/#{app}-#{mode}"
    end
  end
end
