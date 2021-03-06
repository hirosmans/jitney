module Api
  class PassengersController < Api::ApiController
    before_action :set_passenger, only: [:show , :update , :destroy]

    def index
      @passengers = Passenger.all.where(:is_active => true)
      if @passengers 
        respond_with(@passengers)
      else
        respond_with(@passengers)
      end
    end

    def show
      if @passenger
        respond_with(@passenger)
      else
        respond_with(@passenger)
      end
    end

    def create
      @passenger = Passenger.new(email: params['email'], password: params['password'], password_confirmation: params['password_confirmation'])
      @passenger.skip_confirmation!
      if @passenger.save
        respond_with(@passenger)
      else
        respond_with(@passenger)
      end       
    end

    def update
      @passenger = Passenger.update(params[:id], :automatic_map => params[:automatic_map])
      if @passenger.save
        respond_with(@passenger)
      else
        respond_with(@passenger)
      end 
    end

    def destroy
      if @passenger.destroy
        respond_with(@passenger)
      else
        respond_with(@passenger)
      end
    end

    private
      def set_passenger
        @passenger = Passenger.find(params[:id])
      end
  end
end