# = Textable
# === Rmagick dynamic labelled-image generator
#
# :title:Textable
# Author:: Zohar Arad

module Textable
  # enable Textable::ClassMethods when plugin is first included

  def self.included(base)
    base.extend(ClassMethods)
  end

  # configuration class to encapsulate acts_as_textable configuration
  class Config
    # <tt>assets_dir</tt> <String>::
    #   the directory where static assets like fonts and pattern files are saved
    # <tt>cache_dir</tt> <String>::
    #   the directory to write generated files to
    # <tt>image_template</tt> <String>::
    #   the name of the file to use as template for buttons. File should be stored inside assets_dir
    # <tt>font_file</tt> <String>::
    #   the name of the font file to use for generating text on buttons. File should be stored inside assets_dir
    attr_reader :assets_dir, :cache_dir, :image_template, :font_file

    def initialize(options={})
      @assets_dir = options[:assets_dir] || File.join(Rails.root,'public/assets')
      @cache_dir = options[:cache_dir] || File.join(Rails.root,'public/images/cache/textable')
      @image_template = options[:image_template] || File.join(@assets_dir,'user_bg.png')
      @font_file = options[:font] || File.join(@assets_dir,'goldfingerbold.ttf')
    end

  end

  # exposes methods available for Rails controllers for different RMagic functionality
  module ClassMethods

    # enable image resizing in any Rails controller
    #
    # ==== Parameters
    # +options+ <Hash>::
    #   a Hash of options to configure the functionality of the button generation script
    #
    # ===== Options
    # <tt>assets_dir</tt> <String>::
    #   the directory where static assets like fonts and pattern files are saved
    # <tt>cache_dir</tt> <String>::
    #   the directory to write generated files to
    # <tt>image_template</tt> <String>::
    #   the name of the file to use as template for buttons. File should be stored inside assets_dir
    # <tt>font_file</tt> <String>::
    #   the name of the font file to use for generating text on buttons. File should be stored inside assets_dir

    def acts_as_textable(options={})
      @acts_as_textable_config = Textable::Config.new(options)
      include Textable::InstanceMethods
    end

    def acts_as_textable_config
      @acts_as_textable_config || self.superclass.instance_variable_get('@acts_as_textable_config')
    end
  end

	module InstanceMethods
    # Resize any given file according to passed sizes and save into cache directory
    # Note that if the source file is missing, a cached version of the missing-image file will be created and named after the missing source file
    #
    # ==== Parameters
    # +image_text+ <String>::
    #   The text to add to the dynamic image
    # +target_file_name+ <String>::
    #   The name of the file to save as the generated dynamic image
    # +options+ <Hash>::
    #   a Hash of options to configure the functionality of the image generation script
    #
    # ===== Options
    # <tt>reverse</tt> <Boolean>::
    #   should text be revered or not (Useful for RTL languages). Defaults to false
    # <tt>font_size</tt> <Integer>::
    #   font-size to use for the image's dynamic text
    # <tt>color</tt> <String>::
    #   font-color to use for the image's dynamic text
    # <tt>override</tt> <Boolean>::
    #   should cached file be overriden or not. Defaults to false

    def generate_labelled_image(image_text,target_file_name,options={})
      defaults = {:reverse => false,:font_size => 14, :color => 'white', :override => false, :offset => { :x => 0, :y => 0}}
      options = defaults.merge(options)
      config = self.class.acts_as_textable_config
      target_file = File.join(config.cache_dir,"#{target_file_name}.png")
      if !File.exists?(target_file) || options[:override]
        canvas = Magick::Image.read(config.image_template).first
        text = Magick::Draw.new
        text.encoding = 'utf-8'
        text.font = config.font_file
        text.pointsize = options[:font_size]
        if options[:reverse]
          text.gravity = Magick::EastGravity
          str = Rmagickable::reverse(image_text.force_encoding(Encoding::UTF_8))
        else
          text.gravity = Magick::WestGravity
          str = image_text.force_encoding(Encoding::UTF_8)
        end
        text.annotate(canvas, 0,0,options[:offset][:x],options[:offset][:y], str) {
          self.fill = options[:color]
        }
        canvas.format = 'PNG'
        Rmagickable::write_to_cache(config.cache_dir,target_file,canvas)
      end
			return target_file
		end

  end

end