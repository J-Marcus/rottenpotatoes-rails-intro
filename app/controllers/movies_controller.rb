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
    @all_ratings = Movie.get_ratings()
    
    unless params[:ratings].nil?
        @checked_ratings = params[:ratings]
        session[:checked_ratings] = @checked_ratings
    end
    
    if params[:sort].nil?
    else
        session[:sort] = params[:sort]
    end
    
    if params[:sort].nil? && params[:ratings].nil? && session[:checked_ratings]
        @checked_ratings = session[:checked_ratings]        #basically allocate in memory
        @sort = session[:sort]      #basically allocate in memory
        flash.keep      #save to remember!
        redirect_to movies_path({order_by: @sort, ratings: @checked_ratings})   #will let the checkboxes go back to previous state if none is selected
    end
    
    @movies = Movie.all     #default display
    
    if session[:checked_ratings]
        @movies = @movies.select{ |movie| session[:checked_ratings].include? movie.rating}
    end
    
    case session[:sort]
    when 'title'            #highglights the movie title column when selected
        @movies = @movies.sort { |a,b| a.title <=> b.title}
        @movie_highlight = "hilite" #created a class in movies/index.html.haml to use this, 'hilite from default.css'
    when 'release_date'     #highlights the release date column when selected
        @movies = @movies.sort { |a,b| a.release_date <=> b.release_date }
        @release_highlight = "hilite"   #created a class in movies/index.html.haml to use this, 'hilite from default.css'
    else 
        session[:sort] == "release_date"
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
