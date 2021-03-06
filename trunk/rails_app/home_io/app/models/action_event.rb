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


# Events of actions executions

class ActionEvent < ActiveRecord::Base
  belongs_to :action_type
  #belongs_to :user
  belongs_to :executed_by_user, :class_name => "User", :foreign_key => :user_id
  #belongs_to :overseer
  belongs_to :executed_by_overseer, :class_name => "Overseer", :foreign_key => :overseer_id

  validates_presence_of :time

  # will paginate
  cattr_reader :per_page
  @@per_page = 20

  acts_as_commentable

  scope :time_from, lambda {|from|
    tf = from.to_time(:local)
    where ["time >= ?", tf]
    }
  scope :time_to, lambda {|tto|
    tt = tto.to_time(:local)
    where ["time <= ?", tt]
  }
  scope :action_type_id, lambda { |id| where(:action_type_id => id) unless id == 'all' }
  
end
