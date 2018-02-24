module Header.Types exposing (..)

import Common.Types exposing (User)
import Http


type alias Model =
    { user : Maybe User
    , notifications : List Notification
    }


type alias Notification =
    { message : String
    , closed : Bool
    }


type Msg
    = RequestLogOut
    | LogOut (Result Http.Error String)
    | AddNotification String
    | CloseOldestNotification
