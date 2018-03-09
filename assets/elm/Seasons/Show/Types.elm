module Seasons.Show.Types exposing (..)

import Common.Types exposing (User)
import Common.Views.Forms exposing (Error)
import Date exposing (Date)
import Editable exposing (Editable)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , season : Editable Season
    , errors : List (Error FormField)
    , userCanEdit : Bool
    , allPlayers : List Player
    , selectedPlayer : Maybe Player
    }


type alias Player =
    { id : Int
    , firstName : String
    , lastName : String
    , nickname : Maybe String
    }


type alias Season =
    { id : Int
    , title : String
    , start : Maybe Date
    , players : List Player
    }


type alias Flags =
    { location : String }


type PageState
    = Loading
    | Loaded


type FormField
    = Title
    | Start
    | Summary


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchInitialData
    | SetInitialData (Result Http.Error ( User, Season ))
    | EditSeason
    | SetHouseguests (Result Http.Error (List Player))
    | CancelEdit
    | SetTitle String
    | SetStart String
    | SetSelectedPlayer (Maybe Player)
    | AddHouseguest
    | RemoveHouseguest Player
    | SubmitForm
    | SeasonUpdated (Result Http.Error Season)


getSeason : Model -> Season
getSeason model =
    Editable.value model.season
