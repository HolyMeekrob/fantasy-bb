module Leagues.Show.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , league : League
    }


type alias League =
    { id : Int
    , name : String
    , teams : List Team
    , canEdit : Bool
    }


type alias Team =
    { id : Int
    , name : String
    , ownerId : Int
    , ownerName : String
    , logo : String
    , points : Int
    }


type PageState
    = Loading
    | Loaded


type alias Flags =
    { location : String }


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchInitialData
    | SetInitialData (Result Http.Error ( User, League ))
