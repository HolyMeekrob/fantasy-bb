module Leagues.Show.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , league : League
    }


type alias League =
    { id : Int
    , name : String
    }


type alias Flags =
    { location : String }


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchInitialData
    | SetInitialData (Result Http.Error ( User, League ))
