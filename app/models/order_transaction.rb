class OrderTransaction < ActiveRecord::Base
  serialize :params
end
