#!/usr/bin/env ruby

require 'fileutils'

def cp(src, dest)
  if File.readable?(src)
    puts "cp #{src} #{dest}"
    FileUtils.cp(src, dest)
  else
    puts "ERROR: Cannot read #{src}, will not copy to #{dest}"
  end
end

def dir_entries(dir)
  Dir.entries(dir).reject { |x| ['.', '..'].include?(x) }
end

def parse_version(dir)
  File.basename(dir)
  DIR_REGEXES.each do |regex|
    match = regex.match(dir)
    return match[1].to_i.to_s + "." + match[2].to_i.to_s + ".0" if match
  end
  nil
end

DIR_REGEXES = [
  /yjp-[0-9]{4,4}-build-([0-9]{2,2})([0-9]{3,3})/,
  /YourKit_Java_Profiler_[0-9]{4,4}_build_([0-9]{2,2})([0-9]{3,3})\.app/,
]
LIB_REGEX = /.*\.(so|dll|jnilib)$/

BASE_NAME = 'yjp-controller-api-redist'

if ARGV.empty?
  puts "Usage: #{__FILE__} < yjp-20nn-build-xxyyy/ OR YourKit_Java_Profiler_20nn_build_xxyyy.app/ > [output_directory]"
  exit
end

dir = ARGV.shift
version = parse_version(dir)
raise "ERROR: Could not parse version from #{dir}" unless version

target_dir = ARGV.shift || './' + version
Dir.mkdir(target_dir) unless File.directory?(target_dir)

prefix = ''
if RbConfig::CONFIG['host_os'] =~ /(darwin|mac os)/
  prefix = '/Contents/Resources'
end


bin_dir = dir + prefix + '/bin/'
dir_entries(bin_dir).each do |platform|
  next if ['.', '..'].include?(platform)
  path = bin_dir + platform
  next unless File.directory?(path)

  dir_entries(path).each do |lib|
    next unless LIB_REGEX.match(lib)
    lib_name,ext_name = lib.split('.')

    cp(path + '/' + lib, target_dir + '/' + lib_name + '-' + platform + '-' + version + '.' + ext_name)
  end
end

cp(dir + prefix + "/lib/#{BASE_NAME}.jar", target_dir + "/#{BASE_NAME}-#{version}.jar")
cp(dir + prefix + "/license-redist.txt", target_dir)

system("jar -cf #{target_dir}/#{BASE_NAME}-#{version}-sources.jar -C template README")
system("jar -cf #{target_dir}/#{BASE_NAME}-#{version}-javadoc.jar -C template README")

pom_str = File.read('template/pom.xml').gsub('{{version}}', version)
open(target_dir + '/' + BASE_NAME + '-' + version + '.pom', 'w') { |f| f.write pom_str }
