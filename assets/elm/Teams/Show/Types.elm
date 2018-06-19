module Teams.Show.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , team : Team
    }


type alias Team =
    { id : Int
    , name : String
    , ownerId : Int
    , ownerName : String
    , points : Int
    , players : List Player
    , canEdit : Bool
    }


type alias Player =
    { id : Int
    , name : String
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
    | SetInitialData (Result Http.Error ( User, Team ))
