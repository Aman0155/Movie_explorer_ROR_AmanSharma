require 'rails_helper'

RSpec.describe 'API V1 Users', type: :request do
  let(:user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:jwt_token) { "mocked_jwt_token_#{user.id}" }
  let(:supervisor_token) { "mocked_jwt_token_#{supervisor.id}" }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
  let(:supervisor_headers) { { 'Authorization' => "Bearer #{supervisor_token}" } }
  let(:invalid_headers) { { 'Authorization' => 'Bearer invalid_token' } }
  let(:decoded_token) { [{ 'sub' => user.id, 'jti' => user.jti }, { 'alg' => 'HS256' }] }
  let(:supervisor_decoded_token) { [{ 'sub' => supervisor.id, 'jti' => supervisor.jti }, { 'alg' => 'HS256' }] }

  before do
    allow(JWT).to receive(:decode).with(jwt_token, anything, true, { algorithm: 'HS256' }).and_return(decoded_token)
    allow(JWT).to receive(:decode).with(supervisor_token, anything, true, { algorithm: 'HS256' }).and_return(supervisor_decoded_token)
    allow(JWT).to receive(:decode).with('invalid_token', anything, true, hash_including(algorithm: 'HS256')).and_raise(JWT::DecodeError, 'Invalid or expired token')
    allow(JwtBlacklist).to receive(:exists?).and_return(false)
  end

  describe 'GET /api/v1/current_user' do
    context 'when user is signed in' do
      it 'returns the current user with status 200' do
        get '/api/v1/current_user', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['email']).to eq(user.email)
        expect(data['name']).to eq(user.name)
        expect(data['mobile_number']).to eq(user.mobile_number)
        expect(data['role']).to eq('user')
        expect(data['notifications_enabled']).to eq(nil)
      end

      it 'returns the current supervisor with status 200' do
        get '/api/v1/current_user', headers: supervisor_headers, as: :json
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['email']).to eq(supervisor.email)
        expect(data['role']).to eq('supervisor')
      end
    end

    context 'when user is not signed in' do
      it 'returns unauthorized status' do
        get '/api/v1/current_user', headers: invalid_headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['error']).to include('Invalid or expired token')
      end
    end
  end

  describe 'POST /api/v1/update_device_token' do
    context 'with valid parameters' do
      let(:valid_params) { { device_token: 'abc123' } }

      it 'updates the device token for a user and returns status 200' do
        post '/api/v1/update_device_token', params: valid_params, headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(user.reload.device_token).to eq('abc123')
      end

      it 'updates the device token for a supervisor and returns status 200' do
        post '/api/v1/update_device_token', params: valid_params, headers: supervisor_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(supervisor.reload.device_token).to eq('abc123')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { device_token: '' } }

      it 'returns status 200' do
        post '/api/v1/update_device_token', params: invalid_params, headers: headers, as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not signed in' do
      let(:valid_params) { { device_token: 'abc123' } }

      it 'returns unauthorized status' do
        post '/api/v1/update_device_token', params: valid_params, headers: invalid_headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['error']).to include('Invalid or expired token')
      end
    end
  end

  describe 'PATCH /api/v1/toggle_notifications' do
    context 'when user is signed in' do
      it 'toggles notifications from false to true for a user and returns status 200' do
        patch '/api/v1/toggle_notifications', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['notifications_enabled']).to eq(false)
        expect(user.reload.notifications_enabled).to eq(false)
      end

      it 'toggles notifications from false to true for a supervisor and returns status 200' do
        patch '/api/v1/toggle_notifications', headers: supervisor_headers, as: :json
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['notifications_enabled']).to eq(false)
        expect(supervisor.reload.notifications_enabled).to eq(false)
      end

      it 'toggles notifications from true to false for a user and returns status 200' do
        user.update!(notifications_enabled: true)
        patch '/api/v1/toggle_notifications', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['notifications_enabled']).to eq(false)
        expect(user.reload.notifications_enabled).to eq(false)
      end
    end

    context 'when user is not signed in' do
      it 'returns unauthorized status' do
        patch '/api/v1/toggle_notifications', headers: invalid_headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['error']).to include('Invalid or expired token')
      end
    end
  end
end