require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xff_808080)
BOTTOM_COLOR = Gosu::Color.new(0xff_808080)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class Album
  attr_accessor :title, :artist, :artwork, :genre, :tracks
  def initialize(title, artist, artwork, genre, tracks)
    @title = title
    @artist = artist
    @artwork = artwork
    @genre = genre
    @tracks = tracks
  end
end

class ArtWork
	attr_accessor :bmp
	def initialize(file)
		@bmp = Gosu::Image.new(file)
	end
end

class Song
  attr_accessor :song
  def initialize
    @song = Gosu::Song.new(file)
  end
end

class Track
  attr_accessor :song_id, :name, :location
  def initialize(song_id, name, location)
    @song_id = song_id
    @name = name
    @location = location
  end
end

class MusicPlayerMain < Gosu::Window

	def initialize
    super 900, 700
    self.caption = "Personalised Album Player"
    @locn = [60,60]
    @font = Gosu::Font.new(45)
    @yc=0
	end

  # Loading the albums

  def load_album_track()
    def read_track(music_file, input)
      trackkey = input 
      track_name = music_file.gets
      track_location = music_file.gets.chomp
      track = Track.new(trackkey, track_name, track_location)
      return track
    end

  #reading the tracks from the album

    def read_tracks(music_file)
      count = music_file.gets.to_i
      tracks = Array.new()
      index = 0
      while index < count
        track = read_track(music_file, index+1)
        tracks[index] = track  
        index = index+ 1
      end
      return tracks
    end
  
    def read_album(music_file)
      album_title = music_file.gets.chomp
      album_artist = music_file.gets
      album_artwork = music_file.gets.chomp
      album_genre = music_file.gets.to_i
      album_tracks = read_tracks(music_file)
      album = Album.new(album_title, album_artist, album_artwork, album_genre, album_tracks)
      return album
    end
    music_file = File.new("mysong.txt", "r")
    album = read_album(music_file)
    return album
  end
  
  # Artwork on the screen for all the albums
  def draw_album(albm)
    @bmp = Gosu::Image.new(albm.artwork)
    @bmp.draw(300, 100 , z = ZOrder::PLAYER)
  end

# Function to play the track from the album - Evermore
  def playTrack(input)
    album = load_album_track()
    index =0
    while index < album.tracks.length
      if (album.tracks[index].song_id == input)
        @song = Gosu::Song.new(album.tracks[index].location)
        @song.play(false)
      end
    index = index + 1
    end
  end

	def update
    if (@song)
      if (!@song.playing?)
        @yc = @yc+1
        playTrack(@yc)
      end
    end
	end
  
  # Defining the mouse sensitive area , which when clicked on plays the tracks in the album
  #setting the area clicked dimensions according to the size of the image.

  def area_clicked(mouse_x, mouse_y)
    if ((mouse_x > 300 && mouse_x < 580) && (mouse_y > 100 && mouse_y < 378))
      @yc=1
      playTrack(@yc)
    end
  end

  # Code for colored background 

	def draw_background
    draw_quad(0, 0, TOP_COLOR, 0, 700, TOP_COLOR, 900, 0, BOTTOM_COLOR, 900, 700, BOTTOM_COLOR, z= ZOrder::BACKGROUND)
	end

# Drawing the album images and track list for the album

	def draw
		album = load_album_track
    index = 0
    y_absc = 290
    x_ord = 230
		draw_background
    draw_album(album)
    if (!@song)
      @font.draw_text("#{album.title}" " by" " #{album.artist}", x_ord , y_absc+=200, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
    else
      while (index < album.tracks.length)
        @font.draw_text("#{album.tracks[index].name}", x_ord = 310 , y_absc+=88, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
        if(album.tracks[index].song_id == @yc)
          @font.draw_text("#{album.title}" , x_ord += 62 , 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
          @font.draw_text("#", x_ord-90, y_absc, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
        end
        index = index + 1
      end
    end
	end

def needs_cursor?; true; end
	
def button_down(bt)
  case bt 
  when (Gosu::MsLeft)
    @locn = [mouse_x, mouse_y]
    area_clicked(mouse_x, mouse_y)
  end
end
end

MusicPlayerMain.new.show if __FILE__ == $0