class Ability
  include CanCan::Ability

  def initialize(user)

    # this type of data cannot be destroyed
    cannot :destroy, MeasType
    cannot :destroy, MeasArchive
    cannot :destroy, ActionEvent
    cannot :destroy, ActionType

    # not logged user
    if user.nil?
      # can nothing nearly
      # TODO register, sign in
      return
    end

    # logged user
    if user.admin?
      #admin
      can :manage, :all

    else
      # ordinary user
      can :read, [MeasType, MeasArchive, City, ActionType, ActionEvent, ActionTypesUser]
      #can :manage, [Memo], :user_id => user.id
      can :manage, [Memo]
      can :execute, user.action_types

    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
