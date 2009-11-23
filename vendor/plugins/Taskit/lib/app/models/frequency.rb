class Frequency < ActiveRecord::Base
  
  # consts for the different frequencies
  ASAP = 1
  EVERY_FIFTEEN_MINS = 2
  HALF_HOURLY = 3
  HOURLY = 4
  FOUR_TIMES_A_DAY = 5
  TWICE_A_DAY = 6
  DAILY = 7
  WEEKLY = 8
  FORTNIGHTLY = 9
  MONTHLY = 10
  
  has_many :scheduled_tasks
  
end