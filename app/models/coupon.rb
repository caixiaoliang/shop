class Coupon < ApplicationRecord
	attr_accessor :amount, :days,:time_limit

	belongs_to :order
	belongs_to :user

	#绑定优惠券类型  单品 品类 所有产品（Product Category）
	belongs_to :source, polymorphic: true
	
	validates :property, presence: true

	validates :start_date, presence: true, :unless => lambda{|c| c.days.present?}
  	validates :end_date, presence: true, unless: lambda{|c| c.days.present?}

	# validate :check_verify_code, if: lambda{|u| u.mobile.present?},on: :create
	# validates :name, presence: true
	# validate :check_presence_of_account
	validates_uniqueness_of :name

	before_create :generate_uid


	module CouponTypes

		# 优惠券适用范围(单品，品类，全场)
		RangeTypeSingle = "single"
		RangeTypeAll = "all"
		RangeTypeACategory = "category"
		RangeTypesHash = {"单品": RangeTypeSingle, "全场": RangeTypeAll,"品类": RangeTypeACategory}
 		
 		# 使用条件（满减，折扣）
		UseLimitdiscount = "discount"
		UseLimitSubstraction = "substraction"
    	# 无门槛现金券 可以看成 最低消费为0的满减券
    	UseLimitHash = {"折扣券": "discount", "满减券": "substraction"}

    	# 已使用
    	StatusUsed = "used"
    	# 未使用
    	StatusUnused = "unused"
    	# 已过期
    	StatusExpired = "expired"
    	# 冻结
    	StatusFrozen = "frozen"
		
		#未领取 
		StatusInitial = "initial"



	end


	# 领取优惠券
	def draw(user_id)
		self.update_attributes(user_id: user_id)
		after_draw
	end

	# 领取后事务
	def after_draw
		#（相对生效天数） 领取后设置开始和结束时间
		if self.days.present?
			set_relative_date
		end
	end

	#（相对生效天数）设置开始和结束时间
	def set_relative_date
		start_time = Time.now
		end_time  = Time.now.days_since(self.days)
		self.update_attributes(start_date: start_time, end_date: end_time)
	end

	def generate_uid
		self.uid = RandomCode.generate_utoken
	end

	class << self
		def generate_batch_num
			RandomCode.generate_utoken
		end
	end


end
