module V1
    class VehiclesController < ApplicationController
      before_action :set_vehicle, only: [:show, :update, :destroy]

      # GET /vehicles
      def index
        @vehicles = Vehicle.all

        render json: @vehicles
      end

      # GET /vehicles/1
      def show
        render json: @vehicle
      end

      # POST /vehicles
      def create
        @vehicle = Vehicle.new(vehicle_params)

        if @vehicle.save
          render json: @vehicle, status: :created
        else
          render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /vehicles/1
      def update
        if @vehicle.update(vehicle_params)
          render json: @vehicle
        else
          render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /vehicles/1
      def destroy
        @vehicle.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_vehicle
          @vehicle = Vehicle.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def vehicle_params
          params.permit(:vin, :mileage, :make, :model, :customer_id, :color,
            :reservations_attributes => [:id, :_destroy, :vehicle_id, :start_time, :end_time])
        end
    end
end