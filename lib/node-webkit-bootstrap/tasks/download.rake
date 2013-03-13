require "curb"
require "rubygems/package"
require "zlib"
require "zip/zip"

namespace NodeWebkitBootstrap::Rake.app do
  def nw_version 
    "0.4.2"
  end

  def nw_targets
    { linux:  [:ia32, :x64],
      osx: [:ia32],
      win:    [:ia32] }
  end

  def vendor_dirs platform, arch
    here = File.expand_path "..", __FILE__

    [ "#{here}/../vendor/#{platform}/#{arch}",
      # This one is for the app itself. 
      "vendor/node-webkit-bootstrap/#{platform}/#{arch}" ]
  end

  def vendor_deps
    nw_targets.map do |platform, archs|
      archs.map do |arch|
        vendor_dirs(platform,arch).map do |dir|
          Dir["#{dir}/**/*"]
        end.flatten
      end.flatten
    end.flatten
  end

  desc "Download latest node-webkit code (default version: #{nw_version})."
  task :download, [:version] do |t, args|
    version = args[:version] || nw_version
    download_nw version 
  end

  file "tmp/node-webkit" => vendor_deps do
    download_nw
    sh "touch tmp/node-webkit"
  end

  def download_nw version = nw_version
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

  def download_url version, platform, arch, file_extension
    "https://s3.amazonaws.com/node-webkit/v#{version}/node-webkit-v#{version}-#{platform}-#{arch}.#{file_extension}"
  end
end
