module Leagues.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , leagues : LeagueSummary
    }


type alias LeagueSummary =
    { upcoming : List League
    , current : List League
    , complete : List League
    }


type alias League =
    { id : Int
    , name : String
    , teamId : Int
    , teamName : String
    , teamRank : Int
    , teamCount : Int
    , seasonId : Int
    , seasonTitle : String
    }


type PageState
    = Loading
    | Loaded


type Msg
    = HeaderMsg Header.Types.Msg
    | SetInitialData (Result Http.Error ( User, LeagueSummary ))
