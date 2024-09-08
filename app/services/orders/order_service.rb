module Orders
  class OrderService
    attr_reader :params
    attr_accessor :success, :errors, :order, :orders

    def initialize(params = {})
      @params = params
      @success = false
      @errors = []
    end

    def execute_order_creation
      handle_create_order
      self
    end

    def execute_fetch_orders
      handle_fetch_orders
      self
    end

    def execute_order_deletion
      handle_delete_order
      self
    end

    def success?
      @success || @errors.empty?
    end

    def errors
      @errors.join(", ")
    end

    private

    def handle_create_order
      ActiveRecord::Base.transaction do
        order_group = OrderGroup.new(order_params.merge(user_id: user.id))
        if order_group.save!
          @success = true
          @errors = []
          @order = serialize_order(order_group)
        else
          @success = false
          @errors << order_group.errors.full_messages
        end
      end

    rescue ActiveRecord::Rollback => err
      @success = false
      @errors << err.message
    end

    def handle_fetch_orders
      begin
        order_group = OrderGroup.order(created_at: :DESC)
        if order_group.empty?
          @success = false
          @errors << "No orders created yet"
        else
          @success = true
          @errors = []
          @orders = serialize_order(order_group)
        end
      end
    rescue ActiveRecord::ActiveRecordError => err
      @success = false
      @errors << err.message
    end

    def handle_delete_order
      begin
        order_group = OrderGroup.find(params[:order_id])
        if user.admin? && user.id == order_group.user_id
          if order_group.destroy!
            @success = true
            @errors = []
            @order = serialize_order(order_group)
          else
            @success = false
            @errors << order_group.errors.full_messages
          end
        else
          @success = false
          @errors << "You are not authorized to perform this action"
        end
      end
    rescue ActiveRecord::ActiveRecordError => err
      @success = false
      @errors << err.message
    end

    def user
      current_user = params[:current_user]
      user ||= current_user
    end

    def serialize_order(order)
      order.as_json(include: { delivery_order: { include: :line_items } })
    end

    def order_params
      ActionController::Parameters.new(params).permit(:status, :started_at, :completed_at, :customer_id,
        delivery_order_attributes: [ :planned_at, :status, :completed_at, :customer_branch_id, :asset_id,
          line_items_attributes: [ :name, :quantity, :units ]
        ]
      )
    end
  end
end
