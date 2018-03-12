module Leagues.Create.Types exposing (..)

import Common.Types exposing (User)
import Common.Views.Forms exposing (Error)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , name : String
    , season : Maybe Season
    , possibleSeasons : List Season
    , errors : List (Error FormField)
    }


type alias Season =
    { id : Int
    , title : String
    }


type PageState
    = Loading
    | Loaded
    | Error String


type FormField
    = Name
    | Summary


type Msg
    = HeaderMsg Header.Types.Msg
    | SetInitialData (Result Http.Error ( User, List Season ))
    | SetName String
    | SetSelectedSeason (Maybe Season)
    | SubmitForm
    | LeagueCreated (Result Http.Error Int)
