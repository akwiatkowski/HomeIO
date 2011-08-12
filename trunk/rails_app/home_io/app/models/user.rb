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

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    # for available options see documentation in: Authlogic::ActsAsAuthentic
    #c.my_config_option = my_value
    c.logged_in_timeout = 1.day # default is 10.minutes
  end # block optional

  # will paginate
  cattr_reader :per_page
  @@per_page = 20

  has_many :executed_action,
           :class_name => "ActionEvent",
           :foreign_key => :user_id,
           :readonly => true,
           :order => "time DESC"

  # custom names, maybe later
  has_many :action_types_users
  has_many :action_types, :through => :action_types_users

  has_many :memos

  has_many :overseers

  has_many :home_archives

  default_scope :order => 'created_at ASC'

end
