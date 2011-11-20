module ApplicationController::SingleAccessAllowedModule
  def self.inherited(klass)
    super
    klass.extend(ClassMethods)
    class << klass
      attr_accessor :single_access_options
    end
  end

  module ClassMethods
    def single_access_allowed(options=nil)
      self.single_access_options=options
      include(SingleAccessAllowed)
    end
  end

  module SingleAccessAllowed
    def single_access_allowed?
      options=self.class.single_access_options
      return true unless options.kind_of?(Hash)
      return [options[:except]].flatten.compact.index(params[:action].to_sym).nil? if options[:except].present?
      return [options[:only]].flatten.compact.include?(params[:action].to_sym)
    end
  end
end