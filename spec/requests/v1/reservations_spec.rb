RSpec.describe '/v1/reservations' do
  let(:response_hash) { JSON(response.body, symbolize_names: true) }

  describe 'GET to /' do
    it 'returns all reservations' do
      reservation = create(:reservation)

      get v1_reservations_path
      
      expect(response_hash).to eq(
        [
          {
            created_at: reservation.created_at.iso8601(3),
            id: reservation.id,
            updated_at: reservation.updated_at.iso8601(3),
            start_time: reservation.start_time.iso8601(3),
            end_time: reservation.end_time.iso8601(3),
            vehicle_id: reservation.vehicle.id
          }
        ]
      )
    end
  end

  describe 'GET to /:id' do
    context 'when found' do
      it 'returns a reservation' do
        
        reservation = create(:reservation)

        get v1_reservation_path(reservation)

        expect(response_hash).to eq(
          {
            created_at: reservation.created_at.iso8601(3),
            id: reservation.id,
            updated_at: reservation.updated_at.iso8601(3),
            start_time: reservation.start_time.iso8601(3),
            end_time: reservation.end_time.iso8601(3),
            vehicle_id: reservation.vehicle.id
          }
        )
      end
    end

    context 'when not found' do
      it 'returns not_found' do
        
        get v1_reservation_path(-1)
        
        expect(response).to be_not_found
      end
    end
  end

  describe 'POST to /' do
    let(:vehicle) { create(:vehicle) }
    context 'when successful' do
      let(:params) do
        {
            start_time: (Time.zone.now + 1.day).iso8601(3),
            end_time: (Time.zone.now + 1.day + 30.minutes).iso8601(3),
            vehicle_id: Vehicle.first.id
        }
      end

      it 'creates a reservation' do
        
        vehicle
        expect { post v1_reservations_path, params: params }.to change { Reservation.count }
      end

      it 'returns the created reservation' do
        
        vehicle
        post v1_reservations_path, params: params

        expect(response_hash).to include(params)
      end
    end

    context 'when unsuccessful' do
      let(:params) do
        {
        }
      end

      it 'returns an error' do
        
        post v1_reservations_path, params: params

        expect(response_hash).to eq(
          {
            errors: [
              "Vehicle must exist",
              "Start time can't be blank",
              "End time can't be blank"
            ]
          }
        )
      end
    end

    context 'when start time is after end time' do
      let(:params) do
        {
            start_time: (Time.zone.now + 1.day).iso8601(3),
            end_time: (Time.zone.now + 1.day - 30.minutes).iso8601(3),
            vehicle_id: Vehicle.first.id
        }
      end

      it 'returns an error' do
        
        vehicle
        post v1_reservations_path, params: params

        expect(response_hash).to eq(
          {
            errors: [
              "End time can't be before start time"
            ]
          }
        )
      end
    end

    context 'when time ranges overlap' do
      let(:first_reservation) {
        vehicle
        Reservation.create!(
            {
                start_time: (Time.zone.now + 1.day - 10.minutes).iso8601(3),
                end_time: (Time.zone.now + 1.day + 20.minutes).iso8601(3),
                vehicle_id: Vehicle.first.id
            })
      }
      let(:params) do
        {
            start_time: (Time.zone.now + 1.day).iso8601(3),
            end_time: (Time.zone.now + 1.day + 30.minutes).iso8601(3),
            vehicle_id: Vehicle.first.id
        }
      end

      it 'returns an error' do
        
        first_reservation
        post v1_reservations_path, params: params

        expect(response_hash).to eq(
          {
            errors: [
              "Time Ranges for this vehicle can't overlap"
            ]
          }
        )
      end
    end
  end

  describe 'PUT to /:id' do
    let(:reservation) { create(:reservation) }

    context 'when successful' do
      let(:params) do
        {
          end_time: (reservation.start_time + 35.minutes).iso8601(3)
        }
      end

      it 'updates an existing reservation' do
        
        put v1_reservation_path(reservation), params: params

        expect(reservation.reload.end_time).to eq(params[:end_time])
      end

      it 'returns the updated reservation' do
        
        put v1_reservation_path(reservation), params: params

        expect(response_hash).to include(params)
      end
    end

    context 'when unsuccessful' do
      let(:params) do
        {
          end_time: ""
        }
      end

      it 'returns an error' do
        
        put v1_reservation_path(reservation), params: params

        expect(response_hash).to eq(
          {
            errors: ["End time can't be blank"]
          }
        )
      end
    end
  end

  describe 'DELETE to /:id' do
    context 'when successful' do
      let(:reservation) { create(:reservation) }

      it 'deletes a reservation' do
        reservation
        expect { delete v1_reservation_path(reservation) }.to change { Reservation.count }.from(1).to(0)
      end
    end

    context 'when not found' do
      it 'returns 404' do
        delete v1_reservation_path(-1)

        expect(response).to be_not_found
      end
    end
  end
end