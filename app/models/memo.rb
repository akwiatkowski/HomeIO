# Memos written by user at specified time.

class Memo < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :title
end
