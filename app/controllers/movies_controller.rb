class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index   
    @all_ratings = Movie.order(:rating).pluck(:rating).uniq
    

    if params[:ratings]
      session[:ratings] = params[:ratings].keys
      @selected_ratings = params[:ratings].keys
   elsif session[:ratings]
      @selected_ratings = session[:ratings]
    else
      @selected_ratings = @all_ratings
      session[:ratings] = @selected_ratings
    end

    @selected_ratings.each do |rating|
      params[rating] = true
    end
    
    @movies = Movie.where(:rating => @selected_ratings)

    if params[:sort] == 'title'
      session[:sort] = params[:sort]
      @movies = Movie.order(params[:sort]).where(:rating => session[:ratings])
      @title_header = 'hilite'
    end

    if params[:sort] == 'release_date'
      session[:sort] = params[:sort]
      @movies = Movie.order(params[:sort]).where(:rating => session[:ratings])
      @release_header = 'hilite'
    end

    if session[:sort]
      @movies = Movie.order(session[:sort]).where(:rating => session[:ratings])
      session[:sort] == 'release_date' ? @release_header = 'hilite' : @title_header = 'hilite'
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    flash.keep
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    flash.keep
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    flash.keep
    redirect_to movies_path
  end

end
