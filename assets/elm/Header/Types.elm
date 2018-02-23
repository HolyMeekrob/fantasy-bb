module Header.Types exposing (..)

import Common.Types exposing (User)
import Http


type alias Model =
    { user : Maybe User
    , notifications : List String
    }


type Msg
    = RequestLogOut
    | LogOut (Result Http.Error String)
    | AddNotification String
    | ClearOldestNotification
