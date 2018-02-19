module Seasons.Show.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , season : Season
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
    , start : String
    , players : List Player
    }


type alias Flags =
    { location : String }


type PageState
    = Loading
    | View


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchInitialData
    | SetInitialData (Result Http.Error ( User, Season ))
