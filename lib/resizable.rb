# = Resizable
# === Rmagick image resizing module
#
# :title:Resizable
# Author:: Zohar Arad

module Resizable
  # enable Rmagickable::ClassMethods when plugin is first included

  def self.included(base)
    base.extend(ClassMethods)
  end

  # configuration class to encapsulate acts_as_resizable configuration
  class Config
    # <tt>resize_assets_dir</tt> <String>::
    #   the directory where static assets like fonts or missing-image file are saved
    # <tt>resize_cache_dir</tt> <String>::
    #   the directory to write resized / generated files to
    # <tt>resize_src_dir</tt> <String>::
    #   the directory containing files for resizing
    # <tt>missing_image</tt> <String>::
    #   name of the missing image file to serve in case no source file was found. Served from resize_assets_dir
    attr_reader :resize_assets_dir, :resize_cache_dir, :resize_src_dir, :missing_image

    def initialize(options={})
      @resize_assets_dir = options[:resize_assets_dir] || File.join(Rails.root,'public/assets')
      @resize_cache_dir = options[:resize_cache_dir] || File.join(Rails.root,'public/images/cache')
      @resize_src_dir = options[:resize_src_dir] || File.join(Rails.root,'public/images/uploads')
      @missing_image = options[:missing_image] || File.join(@resize_assets_dir,'missing-image.png')
    end

  end

  # exposes methods available for Rails controllers for different RMagic functionality
  module ClassMethods

    # enable image resizing in any Rails controller
    #
    # ==== Parameters
    # +options+ <Hash>::
    #   a Hash of options to configure the functionality of the resizing script
    #
    # ===== Options
    # <tt>resize_assets_dir</tt> <String>::
    #   the directory where static assets like fonts or missing-image file are saved
    # <tt>resize_cache_dir</tt> <String>::
    #   the directory to write resized / generated files to
    # <tt>resize_src_dir</tt> <String>::
    #   the directory containing files for resizing
    # <tt>missing_image</tt> <String>::
    #   name of the missing image file to serve in case no source file was found. Served from resize_assets_dir

    def acts_as_resizable(options={})
      @acts_as_resizable_config = Resizable::Config.new(options)
      include Resizable::InstanceMethods
    end

    def acts_as_resizable_config
      @acts_as_resizable_config || self.superclass.instance_variable_get('@acts_as_resizable_config')
    end
  end

	module InstanceMethods
    # Resize any given file according to passed sizes and save into cache directory
    # Note that if the source file is missing, a cached version of the missing-image file will be created and named after the missing source file
    # 
    # ==== Parameters
    # +file+ <String>::
    #   Path to the file to resize, relative to +@resize_src_dir+
    # +size+ <String>::
    #   width and height to resize the file to, in the format +WxH+
    #   Example: 200x80
    def get_resized_file(file,size)
      sizes = size.split('x')
      src_file = File.join(self.class.acts_as_resizable_config.resize_src_dir,file)
      cached_file = File.join(self.class.acts_as_resizable_config.resize_cache_dir,size,file)
      resize_cache_dir = File.dirname(cached_file)
      unless File.exists?(cached_file)
        FileUtils.mkdir_p(resize_cache_dir) unless File.directory?(resize_cache_dir)
        unless File.exists?(src_file)
          src_file = self.class.acts_as_resizable_config.missing_image
        end
        img = Magick::Image.read(src_file).first
        thumb = img.resize_to_fill(sizes[0].to_i,sizes[1].to_i)
        thumb.write(cached_file)
      end
      return cached_file
    end
  end

end