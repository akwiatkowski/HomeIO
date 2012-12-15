# http://stackoverflow.com/questions/8899272/rails-3-undefined-method-zero-for-nilnilclass-in-many-to-many-relationsh

class NilClass
  def zero?
    true
  end
end