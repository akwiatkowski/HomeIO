module ApplicationController::AncestorHandling

  private

  # Get object which has first level inherited resources
  # Usable ex. for comments
  def ancestor_object
    object_key = params.keys.select { |k| k.to_s =~ /_id/ }.first
    object_type = object_key.gsub(/_id/, '').camelize
    return object_type.constantize.find(params[object_key])
  end

  # Load and authorize super object for reading
  def load_and_authorize_ancestor_object
    @ancestor = ancestor_object
    authorize! :read, @ancestor.class
  end

end