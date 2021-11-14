RSpec.describe '/v1/vehicles' do
  let(:response_hash) { JSON(response.body, symbolize_names: true) }

  describe 'GET to /' do
    it 'returns all vehicles' do
      vehicle = create(:vehicle)

      get v1_vehicles_path
      
      expect(response_hash).to eq(
        [
          {
            created_at: vehicle.created_at.iso8601(3),
            id: vehicle.id,
            updated_at: vehicle.updated_at.iso8601(3),
            vin: vehicle.vin,
            mileage: vehicle.mileage,
            make: vehicle.make,
            model: vehicle.model,
            customer_id: vehicle.customer.id,
            color: vehicle.color
          }
        ]
      )
    end
  end

  describe 'GET to /:id' do
    context 'when found' do
      it 'returns a vehicle' do
        vehicle = create(:vehicle)

        get v1_vehicle_path(vehicle)

        expect(response_hash).to eq(
          {
            created_at: vehicle.created_at.iso8601(3),
            id: vehicle.id,
            updated_at: vehicle.updated_at.iso8601(3),
            vin: vehicle.vin,
            mileage: vehicle.mileage,
            make: vehicle.make,
            model: vehicle.model,
            customer_id: vehicle.customer.id,
            color: vehicle.color
          }
        )
      end
    end

    context 'when not found' do
      it 'returns not_found' do
        get v1_vehicle_path(-1)
        
        expect(response).to be_not_found
      end
    end
  end

  describe 'POST to /' do
    let(:customer) { create(:customer) }
    context 'when successful' do
      let(:params) do
        {
            vin: "12A1234567AB123",
            mileage: 45000,
            make: "Ford",
            model: "Focus",
            customer_id: Customer.first.id,
            color: "Green"
        }
      end

      it 'creates a vehicle' do
        customer
        expect { post v1_vehicles_path, params: params }.to change { Vehicle.count }
      end

      it 'returns the created vehicle' do
        customer
        post v1_vehicles_path, params: params

        expect(response_hash).to include(params)
      end
    end

    context 'when unsuccessful' do
      let(:params) do
        {
        }
      end

      it 'returns an error' do
        
        post v1_vehicles_path, params: params

        expect(response_hash).to eq(
          {
            errors: [
              "Customer must exist",
              "Vin can't be blank",
              "Make can't be blank",
              "Model can't be blank",
              "Color can't be blank"
            ]
          }
        )
      end
    end

    context 'when there are nested attributes' do
      let(:params) do
        {
            vin: "12EH1283919",
            mileage: 54678,
            make: "Honda",
            model: "Accord",
            color: "Blue",
            customer_id: Customer.first.id,
            reservations_attributes: [{
              start_time: Time.now+1.day,
              end_time: Time.now+1.1.days
            }]
        }
      end

      it 'creates them correctly' do
        customer
        expect { post v1_vehicles_path, params: params }.to change { Vehicle.count }
                                                          .and change { Reservation.count }
      end
    end
  end

  describe 'PUT to /:id' do
    let(:vehicle) { create(:vehicle) }

    context 'when successful' do
      let(:params) do
        {
          color: "Cerulean"
        }
      end

      it 'updates an existing vehicle' do
        
        put v1_vehicle_path(vehicle), params: params

        expect(vehicle.reload.color).to eq(params[:color])
      end

      it 'returns the updated vehicle' do
        
        put v1_vehicle_path(vehicle), params: params

        expect(response_hash).to include(params)
      end
    end

    context 'when unsuccessful' do
      let(:params) do
        {
          color: ""
        }
      end

      it 'returns an error' do
        
        put v1_vehicle_path(vehicle), params: params

        expect(response_hash).to eq(
          {
            errors: ["Color can't be blank"]
          }
        )
      end
    end

    context 'when there are nested attributes' do
      let(:vehicle) {
        create(:reservation).vehicle
      }
      let(:params) do
        {
          reservations_attributes: [{
            id: vehicle.reservations.reload.first.id,
            start_time: Time.zone.now + 1.day,
            end_time: Time.zone.now + 1.day + 30.minutes #this will cause issues if you run the tests at exactly midnight on Sunday
          }]
        }
      end

      it 'updates them correctly' do
        
        put v1_vehicle_path(vehicle), params: params
        expect(vehicle.reservations.reload.first.end_time).to be_within(1.second).of params[:reservations_attributes][0][:end_time]
      end
    end
  end

  describe 'DELETE to /:id' do
    context 'when successful' do
      let(:vehicle) { create(:vehicle) }

      it 'deletes a vehicle' do
        
        vehicle
        expect { delete v1_vehicle_path(vehicle) }.to change { Vehicle.count }.from(1).to(0)
      end
    end

    context 'when not found' do
      it 'returns 404' do
        
        delete v1_vehicle_path(-1)

        expect(response).to be_not_found
      end
    end

    context 'when there are nested attributes' do
      let(:vehicle) {
        create(:reservation).vehicle
      }

      it 'deletes them correctly' do
        
        vehicle
        expect { put v1_vehicle_path(vehicle), params: 
            {
                reservations_attributes: [{
                    id: vehicle.reservations.reload.first.id,
                    _destroy: 1
                }]
            }
          }.to change { Reservation.count }
      end
    end
  end
end