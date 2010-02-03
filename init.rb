ActionController::Base.class_eval do
  include Rmagickable
end

ActiveRecord::Base.class_eval do
  include RmagickConvertable
end