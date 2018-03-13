module Leagues.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    }


type PageState
    = Loading
    | Loaded


type Msg
    = HeaderMsg Header.Types.Msg
    | SetInitialData (Result Http.Error User)
