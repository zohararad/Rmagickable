require 'RMagick'
include Magick

# = Rmagickable
# === A simple rails plugin that exposes RMagick functionality in Rails controllers
#
# :title:Rmagicable
# Author:: Zohar Arad
# Requires:: RMagic

module Rmagickable
  # include Rmagickable modules
  include Resizable
  include Buttonable
  include Textable
  def self.included(base)
    base.extend(Resizable::ClassMethods,Buttonable::ClassMethods,Textable::ClassMethods)
  end
  
  def self.reverse(orig)
    src = orig.reverse.to_s
    tgt = ''
    tmp = []
    src.each_char do |c|
      if c =~ /[a-zA-Z0-9]/
        tmp << c
      else
        if tmp.length > 0
          tgt += tmp.reverse.join('')
          tmp.clear
        end
      tgt += c
      end
    end
    if tmp.length > 0
      tgt += tmp.reverse.join('')
      tmp.clear
    end
    tgt
  end

  def self.write_to_cache(cache_dir,file,rmagick_resource)
    FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
    rmagick_resource.write(file)
  end
end