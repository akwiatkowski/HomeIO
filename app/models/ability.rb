class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, MeasTypeGroup
    can :read, MeasType
    can :read, MeasArchive
    can :manage, Overseer

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
