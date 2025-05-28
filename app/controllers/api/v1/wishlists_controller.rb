module Api
  module V1
    class WishlistsController < ApplicationController
      before_action :authenticate_user!
      skip_before_action :verify_authenticity_token
      before_action :set_wishlist, only: [:destroy]

      def index
        @wishlists = @current_user.wishlists.includes(:movie).where(movies: { id: Movie.accessible_to_user(@current_user) })
        if @wishlists.any?
          serialized = @wishlists.map { |wishlist| WishlistSerializer.new(wishlist.movie).serializable_hash }
          render json: { message: "Wishlist retrieved successfully", data: serialized }, status: :ok
        else
          render json: { message: "Your wishlist is empty", data: [] }, status: :ok
        end
      end

      def create
        Rails.logger.info "Params: #{params.inspect}"
        Rails.logger.info "Wishlist Params: #{params[:wishlist].inspect}"
        Rails.logger.info "Movie ID: #{params[:wishlist][:movie_id].inspect}"

        movie_id = params.dig(:wishlist, :movie_id)&.to_i
        unless movie_id
          render json: { errors: ["movie_id is required"] }, status: :bad_request
          return
        end

        movie = Movie.find_by(id: movie_id)
        if movie
          if Movie.accessible_to_user(@current_user).where(id: movie.id).exists?
            @wishlist = @current_user.wishlists.new(movie_id: movie_id)
            if @wishlist.save
              render json: { 
                message: "Movie added to wishlist", 
                data: WishlistSerializer.new(@wishlist.movie).serializable_hash 
              }, status: :created
            else
              render json: { errors: @wishlist.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { errors: ["Movie is not accessible to your subscription"] }, status: :forbidden
          end
        else
          render json: { errors: ["Movie not found"] }, status: :not_found
        end
      end

      def destroy
        if @wishlist.destroy
          render json: { message: "Movie removed from wishlist" }, status: :ok
        else
          render json: { errors: @wishlist.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_wishlist
        @wishlist = @current_user.wishlists.find_by(movie_id: params[:id])
        unless @wishlist
          render json: { error: "Movie not found in your wishlist" }, status: :not_found
        end
      end
    end
  end
end