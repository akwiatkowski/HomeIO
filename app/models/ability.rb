class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, MeasType

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
