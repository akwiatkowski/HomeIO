#!/usr/bin/ruby
#encoding: utf-8

# HomeIO - home control system.
# Copyright (C) 2011 Aleksander Kwiatkowski
#
# This file is part of HomeIO.
#
# HomeIO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HomeIO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.

class Ability
  include CanCan::Ability

  def initialize(user)

    # this type of data cannot be destroyed
    cannot :destroy, MeasType
    cannot :destroy, MeasArchive
    cannot :destroy, ActionEvent
    cannot :destroy, ActionType

    cannot :destroy, WeatherArchive
    cannot :destroy, WeatherMetarArchive

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
      can :read, [MeasType, MeasArchive, City, ActionType, ActionEvent, ActionTypesUser, Memo, Overseer, HomeArchive, WeatherArchive, WeatherMetarArchive, MeasTypeGroup]

      # only edit self memos
      can :manage, user.memos
      # can create new memos
      can :create, Memo

      can :execute, user.action_types

      # only edit self overseers
      can :manage, user.overseers
      # can create new overseers
      can :create, Overseer

      # can create and update owned
      can :create, HomeArchive
      can :manage, user.home_archives
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
